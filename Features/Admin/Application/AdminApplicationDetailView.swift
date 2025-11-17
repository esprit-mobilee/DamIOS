import SwiftUI

struct AdminApplicationDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let application: Application

    @State private var internship: InternshipOffer? = nil
    @State private var userProfile: EspritUser? = nil

    @State private var selectedStatus = ""
    @State private var showStatusAlert = false

    var body: some View {

        ScrollView {
            VStack(spacing: 26) {

                // HEADER
                VStack(alignment: .leading, spacing: 10) {
                    Text("Dossier de candidature")
                        .font(.largeTitle.bold())

                    statusBadge(application.status)

                    if let date = application.submittedAt {
                        Label(date, systemImage: "calendar")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 28).fill(.white))
                .shadow(radius: 4)

                // STAGE
                modernSection(title: "Stage") {
                    Text(internship?.title ?? "Stage #\(application.internshipId?.id.prefix(5) ?? "")")
                }

                // USER
                modernSection(title: "Candidat") {
                    Text(userProfile?.fullName ?? "Utilisateur #\(application.userId.prefix(5))")
                }

                // CV
                modernSection(title: "CV") {
                    if let url = URL(string: application.cvUrl) {
                        Link("Télécharger le CV", destination: url)
                            .foregroundColor(.blue)
                    }
                }

                // LETTER
                if let lettre = application.coverLetter {
                    modernSection(title: "Lettre de motivation") {
                        Text(lettre)
                            .foregroundColor(.gray)
                    }
                }

                // ACTIONS
                VStack(spacing: 16) {
                    adminButton("Accepter", color: .green) {
                        selectedStatus = "accepted"
                        showStatusAlert = true
                    }

                    adminButton("Refuser", color: .red) {
                        selectedStatus = "rejected"
                        showStatusAlert = true
                    }
                }
                .padding(.vertical, 10)
            }
            .padding()
        }
        .navigationTitle("Candidature")
        .task { await loadExtraData() }
        .alert(isPresented: $showStatusAlert) {
            Alert(
                title: Text("Confirmer"),
                message: Text("Changer le statut en « \(selectedStatus) » ?"),
                primaryButton: .destructive(Text("Oui")) {
                    Task { await updateStatus() }
                },
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: — COMPONENTS

    private func statusBadge(_ status: String) -> some View {
        let color: Color =
            status == "accepted" ? .green :
            status == "rejected" ? .red :
            .orange

        return Text(status.capitalized)
            .bold()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private func modernSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(.white))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }

    private func adminButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(16)
        }
    }

    // MARK: — LOAD DATA
    private func loadExtraData() async {
        guard let token = appState.token else { return }

        async let offer = try? await EspritAPI.shared.getInternshipById(token: token, id: application.internshipId?.id ?? "")
        async let user = try? await EspritAPI.shared.getUserById(token: token, id: application.userId ?? "")

        internship = await offer
        userProfile = await user
    }

    // MARK: — UPDATE STATUS
    private func updateStatus() async {
        guard let token = appState.token else { return }
        do {
            _ = try await EspritAPI.shared.updateApplicationStatus(
                token: token,
                id: application.id ?? "",
                status: selectedStatus
            )
            dismiss()
        } catch {
            print("Erreur:", error)
        }
    }
}
