import SwiftUI

struct EventDetailView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // IMPORTANT : event doit être @State pour rafraîchir la vue après édition
    @State var event: Event

    @State private var showDeleteAlert = false
    @State private var isSharing = false
    @State private var showEdit = false      // ← CORRECT

    private var canManage: Bool {
        guard let roles = appState.currentUser?.roles else { return false }
        return roles.contains(.ADMIN) || roles.contains(.PRESIDENT)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: IMAGE
                AsyncImage(url: event.fullImageURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFit()
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .padding(30)
                            .foregroundColor(.gray.opacity(0.4))
                    default:
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // MARK: INFOS
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .font(.title2.bold())

                    if let loc = event.location, !loc.isEmpty {
                        Label(loc, systemImage: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                    }

                    Text(formatDate(event.date))
                        .foregroundColor(.gray)

                    if let cat = event.category, !cat.isEmpty {
                        Label(cat, systemImage: "tag")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                Divider()

                // MARK: DESCRIPTION
                if let desc = event.description, !desc.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(desc)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    Divider()
                }

                // MARK: ACTIONS
                if canManage {
                    HStack(spacing: 40) {

                        // EDIT
                        Button {
                            showEdit = true
                        } label: {
                            actionIcon(system: "square.and.pencil", color: .blue)
                        }

                        // SHARE
                        Button { isSharing = true } label: {
                            actionIcon(system: "square.and.arrow.up", color: .green)
                        }
                        .sheet(isPresented: $isSharing) {
                            ActivityViewController(activityItems: [
                                "\(event.title)\n\(event.description ?? "")"
                            ])
                        }

                        // DELETE
                        Button { showDeleteAlert = true } label: {
                            actionIcon(system: "trash", color: .red)
                        }
                    }
                    .padding(.vertical, 20)
                }

            }
            .padding(.vertical)
        }
        .navigationTitle("Événement")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: ✨ EDIT SHEET (corrected)
        .sheet(isPresented: $showEdit) {
            AdminEditEventView(event: $event, token: appState.token!)
                .environmentObject(appState)
        }

        .alert("Supprimer cet événement ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) {}

            Button("Supprimer", role: .destructive) {
                Task { await deleteEvent() }
            }
        } message: {
            Text("Cette action est irréversible.")
        }
    }

    private func deleteEvent() async {
        guard let token = appState.token else { return }
        do {
            try await EspritAPI.shared.deleteEvent(token: token, id: event.id)
            dismiss()
        } catch {
            print("❌ Erreur:", error.localizedDescription)
        }
    }

    private func formatDate(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        guard let date = f.date(from: iso) else { return iso }
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }

    @ViewBuilder
    func actionIcon(system: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 60, height: 60)

            Image(systemName: system)
                .font(.title2)
                .foregroundColor(color)
        }
    }
}

// MARK: - SHARE SHEET
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
