import SwiftUI

struct StudentMyApplicationsForStageView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = StudentApplicationsViewModel()

    let internshipId: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                if vm.isLoading {
                    ProgressView("Chargement…")
                        .padding(.top, 50)

                } else if vm.applications.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.4))

                        Text("Aucune candidature pour ce stage.")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 80)

                } else {

                    // 🔥 ICI : les cartes deviennent cliquables
                    // 🔥 Cartes cliquables AVEC BINDING
                    ForEach(Array(vm.applications.enumerated()), id: \.1.id) { index, app in
                        NavigationLink {
                            StudentApplicationDetailView(application: $vm.applications[index])
                                .environmentObject(appState)
                        } label: {
                            applicationCard(app)
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity.combined(with: .slide))
                    }

                }
            }
            .padding()
        }
        .navigationTitle("Mes candidatures")
        .task {
            if let token = appState.token,
               let userId = appState.currentUser?.id {
                await vm.loadApplicationsForStage(
                    token: token,
                    internshipId: internshipId,
                    userId: userId
                )
            }
        }
    }

    // MARK: - MODERN CARD UI
    private func applicationCard(_ app: Application) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            // HEADER
            HStack {
                Text("Candidature")
                    .font(.title3.bold())

                Spacer()

                statusBadge(app.status)
            }

            Divider()

            // DATE
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundColor(.red)

                Text(formatDate(app.submittedAt ?? ""))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // CV SECTION
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .foregroundColor(.red)

                Link("Voir le CV", destination: URL(string: app.cvUrl)!)
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
            }

        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // MARK: - STATUS BADGE
    private func statusBadge(_ status: String) -> some View {
        let color: Color =
            status == "accepted" ? .green :
            status == "rejected" ? .red :
            .orange

        return Text(status.capitalized)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    // MARK: - DATE FORMATTER
    private func formatDate(_ raw: String) -> String {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: raw) {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            return f.string(from: date)
        }
        return raw
    }
}
