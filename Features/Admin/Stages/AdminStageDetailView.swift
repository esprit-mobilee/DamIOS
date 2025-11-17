import SwiftUI

struct AdminStageDetailView: View {
    let offer: InternshipOffer
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var isSharing = false

    private var logoURL: URL? {
        offer.logoFullURL
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - IMAGE
                AsyncImage(url: logoURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .foregroundColor(.gray.opacity(0.4))
                    default:
                        ProgressView().frame(height: 100)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // MARK: - TITRE + ENTREPRISE
                VStack(alignment: .leading, spacing: 6) {
                    Text(offer.title)
                        .font(.title2).bold()

                    Text(offer.company)
                        .foregroundColor(.gray)
                        .font(.headline)

                    if let loc = offer.location {
                        Label(loc, systemImage: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)

                Divider()

                // MARK: - DESCRIPTION
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description").font(.headline)
                    Text(offer.description)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                Divider()

                // MARK: - AUTRES INFOS
                VStack(alignment: .leading, spacing: 10) {
                    Label("Durée : \(offer.duration) semaines", systemImage: "clock")
                    if let salary = offer.salary {
                        Label("Salaire : \(salary) DT", systemImage: "banknote")
                    }
                }
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.horizontal)

                Divider()

                // MARK: - ACTIONS ADMIN
                HStack(spacing: 30) {

                    NavigationLink {
                        AdminEditInternshipView(token: appState.token!, offer: offer) { _ in
                            dismiss()
                        }
                    } label: {
                        actionIcon(system: "square.and.pencil", color: .blue)
                    }

                    Button {
                        isSharing = true
                    } label: {
                        actionIcon(system: "square.and.arrow.up", color: .green)
                    }
                    .sheet(isPresented: $isSharing) {
                        ActivityViewController(activityItems: [
                            "\(offer.title) — \(offer.company)\n\(offer.description)"
                        ])
                    }

                    Button {
                        showDeleteAlert = true
                    } label: {
                        actionIcon(system: "trash", color: .red)
                    }
                }
                .padding(.vertical, 20)
                // MARK: - Candidatures (ADMIN UNIQUEMENT)
                if let roles = appState.currentUser?.roles,
                   roles.contains(.ADMIN) {

                    NavigationLink("Voir les candidatures") {
                        AdminApplicationsListView(offerId: offer.id)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 10)
                }



            }
            .padding(.vertical)
        }
        .navigationTitle("Détails du stage")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.espritBgGray.ignoresSafeArea())
        .alert("Supprimer ce stage ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) {}

            Button("Supprimer", role: .destructive) {
                Task { await deleteOffer() }
            }
        } message: {
            Text("Cette action est irréversible.")
        }
    }

    private func deleteOffer() async {
        guard let token = appState.token else { return }
        isDeleting = true

        do {
            try await EspritAPI.shared.deleteInternshipOffer(token: token, id: offer._id)
            dismiss()
        } catch {
            print("Erreur suppression :", error.localizedDescription)
        }

        isDeleting = false
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
    // MARK: - SHARE SHEET
    struct ActivityViewController: UIViewControllerRepresentable {
        let activityItems: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}
