import SwiftUI
import PhotosUI

struct AdminAddEventView: View {
    let token: String
    var onSaved: (Event) -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var category = ""
    @State private var image: UIImage?

    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - VALIDATION RULES
    private var isTitleValid: Bool { title.trimmingCharacters(in: .whitespaces).count >= 3 }
    private var isDescriptionValid: Bool { descriptionText.isEmpty || descriptionText.count >= 5 }
    private var canSave: Bool { isTitleValid && isDescriptionValid }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - INFOS
                Section("Informations générales") {
                    TextField("Titre de l’événement", text: $title)
                    if !isTitleValid {
                        Text("Le titre doit contenir au moins 3 caractères.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    TextField("Lieu", text: $location)
                    TextField("Catégorie", text: $category)
                }

                // MARK: - DATE
                Section("Date") {
                    DatePicker("Date & heure", selection: $date)
                }

                // MARK: - DESCRIPTION
                Section("Description") {
                    TextEditor(text: $descriptionText)
                        .frame(height: 110)

                    if !isDescriptionValid {
                        Text("La description doit contenir au moins 5 caractères si renseignée.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // MARK: - IMAGE
                Section("Affiche / Image") {
                    PhotosPicker("Choisir une image", selection: Binding(
                        get: { nil },
                        set: { item in
                            if let item {
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let img = UIImage(data: data) {
                                        await MainActor.run { self.image = img }
                                    }
                                }
                            }
                        }
                    ))

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(12)
                    }
                }

                // MARK: - ERREUR API
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }

            // MARK: - TOOLBAR
            .navigationTitle("Ajouter un événement")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isLoading ? "..." : "Enregistrer") {
                        Task { await save() }
                    }
                    .disabled(!canSave)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }

    // MARK: - SAVE
    private func save() async {
        isLoading = true
        defer { isLoading = false }

        guard let organizerId = appState.currentUser?.id else {
            errorMessage = "Impossible de récupérer votre identifiant."
            return
        }

        do {
            let iso = ISO8601DateFormatter().string(from: date)

            let event = try await EspritAPI.shared.createEvent(
                token: token,
                title: title,
                description: descriptionText.isEmpty ? nil : descriptionText,
                date: iso,
                location: location.isEmpty ? nil : location,
                category: category.isEmpty ? nil : category,
                organizerId: organizerId,
                image: image
            )

            await MainActor.run {
                onSaved(event)
                dismiss()
            }
        }
        catch {
            await MainActor.run {
                errorMessage = "Erreur : \(error.localizedDescription)"
            }
        }
    }
}
