import SwiftUI
import PhotosUI

struct AdminAddClubView: View {
    let token: String
    var onSaved: ((Club) -> Void)?
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var descriptionText = ""
    @State private var president = ""
    @State private var tagsText = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var errorMessage: String?

    // MARK: - VALIDATION
    private var isNameValid: Bool { name.trimmingCharacters(in: .whitespaces).count >= 3 }
    private var isPresidentValid: Bool {
        president.isEmpty || president.count > 2
    }

    private var areTagsValid: Bool { true } // ils sont optionnels
    private var canSave: Bool {
        isNameValid && isPresidentValid
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Infos
                Section("Infos du club") {
                    TextField("Nom du club", text: $name)
                    if !isNameValid {
                        Text("Le nom doit contenir au moins 3 caractères.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    TextField("Description", text: $descriptionText)
                }

                // MARK: Image
                Section("Image du club") {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Text("Choisir une image")
                    }

                    if let data = imageData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(12)
                    }
                }
                .onChange(of: selectedImage) { _ in
                    Task {
                        imageData = try? await selectedImage?.loadTransferable(type: Data.self)
                    }
                }

                // MARK: Président
                Section("Président") {
                    TextField("ID mongo du président", text: $president)
                        .autocorrectionDisabled()

                    if !isPresidentValid {
                        Text("L’ID doit contenir au moins caractères (ObjectID MongoDB).")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // MARK: Tags
                Section("Tags") {
                    TextField("robotique, innovation", text: $tagsText)
                }

                // MARK: Erreur API
                if let err = errorMessage {
                    Text(err).foregroundColor(.red)
                }
            }

            // MARK: Toolbar
            .navigationTitle("Nouveau club")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
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

    // MARK: Save
    private func save() async {
        do {
            let tags = tagsText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }

            let club = try await EspritAPI.shared.createClub(
                token: token,
                name: name,
                description: descriptionText.isEmpty ? nil : descriptionText,
                president: president.isEmpty ? nil : president,
                tags: tags.isEmpty ? nil : tags.map { String($0) },
                image: imageData
            )

            await MainActor.run {
                onSaved?(club)
                dismiss()
            }

        } catch {
            await MainActor.run {
                errorMessage = "Erreur ajout club : \(error.localizedDescription)"
            }
        }
    }
}
