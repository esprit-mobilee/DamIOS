import SwiftUI

struct ApplyForInternshipView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = StudentApplicationsViewModel()

    let internshipId: String

    @State private var cvUrl = ""
    @State private var coverLetter = ""

    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("CV (.pdf) obligatoire") {
                    TextField("URL de votre CV", text: $cvUrl)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section("Lettre de motivation") {
                    TextEditor(text: $coverLetter)
                        .frame(height: 120)
                }
            }
            .navigationTitle("Postuler")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Envoyer") {
                        Task { await validateAndSubmit() }
                    }
                }
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func validateAndSubmit() async {
        guard let token = appState.token,
              let userId = appState.currentUser?.id else { return }

        let trimmed = cvUrl.trimmingCharacters(in: .whitespaces)

        // 🔥 1) CV obligatoire
        guard !trimmed.isEmpty else {
            showError(message: "Le lien du CV est obligatoire.")
            return
        }

        // 🔥 2) Doit être un PDF
        guard trimmed.lowercased().hasSuffix(".pdf") else {
            showError(message: "Le CV doit être un fichier PDF (terminer par .pdf).")
            return
        }

        // 🔥 3) URL valide
        guard URL(string: trimmed) != nil else {
            showError(message: "Veuillez saisir une URL valide.")
            return
        }

        // 🔥 4) Lettre de motivation minimale
        if !coverLetter.isEmpty && coverLetter.count < 10 {
            showError(message: "Votre lettre doit contenir au moins 10 caractères.")
            return
        }

        let success = await vm.createApplication(
            token: token,
            userId: userId,
            internshipId: internshipId,
            cvUrl: trimmed,
            coverLetter: coverLetter
        )

        if success { dismiss() }
    }

    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
