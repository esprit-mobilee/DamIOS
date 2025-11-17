import SwiftUI

struct EditApplicationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @Binding var application: Application      // ← Binding = mise à jour auto

    @State private var coverLetter: String = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {

        NavigationStack {
            Form {

                Section("Lettre de motivation") {
                    TextEditor(text: $coverLetter)
                        .frame(height: 130)
                }
            }
            .navigationTitle("Modifier")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveChanges()
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Enregistrer")
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .onAppear {
                coverLetter = application.coverLetter ?? ""
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - SAVE
    private func saveChanges() {
        guard let token = appState.token else { return }
        isSaving = true

        Task {
            do {
                let updated = try await EspritAPI.shared.updateApplication(
                    token: token,
                    id: application.id,
                    coverLetter: coverLetter
                )

                application = updated     // ← Mise à jour instantanée de StudentApplicationDetailView

                dismiss()

            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }

            isSaving = false
        }
    }
}
