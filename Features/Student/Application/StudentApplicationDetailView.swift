import SwiftUI

struct StudentApplicationDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @Binding var application: Application
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: — Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Candidature")
                        .font(.largeTitle).bold()

                    statusBadge(application.status)

                    if let date = application.submittedAt {
                        Label(formatDate(date), systemImage: "calendar")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 4))

                // MARK: — CV
                VStack(alignment: .leading, spacing: 8) {
                    Text("CV").font(.headline)

                    if let url = URL(string: application.cvUrl) {
                        Link("Télécharger", destination: url)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 4))

                // MARK: — Lettre de motivation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lettre de motivation").font(.headline)
                    Text(application.coverLetter ?? "Aucune lettre")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 4))

                // MARK: — Boutons
                Button {
                    showEditSheet = true
                } label: {
                    Text("Modifier")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Supprimer")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.12))
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding()
        }
        .navigationTitle("Détails")

        // MARK: — SHEET POUR MODIFIER
        .sheet(isPresented: $showEditSheet) {
            EditApplicationView(application: $application)
                .environmentObject(appState)
        }

        // MARK: — ALERT POUR SUPPRESSION (MANQUANTE AVANT !)
        .alert("Supprimer cette candidature ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                Task { await deleteApplication() }
            }
        } message: {
            Text("Cette action est définitive.")
        }
    }

    // STATUS BADGE
    private func statusBadge(_ s: String) -> some View {
        let color: Color = s == "accepted" ? .green : s == "rejected" ? .red : .orange

        return Text(s.capitalized)
            .bold()
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    // FORMAT DATE
    private func formatDate(_ raw: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let d = formatter.date(from: raw) {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            return f.string(from: d)
        }
        return raw
    }

    // MARK: — DELETE API CALL
    private func deleteApplication() async {
        guard let token = appState.token else { return }

        do {
            try await EspritAPI.shared.deleteApplication(token: token, id: application.id)
            dismiss()   // ← retourne vers la liste
        } catch {
            print("Erreur suppression :", error.localizedDescription)
        }
    }
}
