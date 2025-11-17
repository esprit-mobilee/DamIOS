import SwiftUI
import PhotosUI

struct AdminEditClubView: View {
    let token: String
    let club: Club
    var onSaved: ((Club) -> Void)?

    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var descriptionText = ""
    @State private var president = ""
    @State private var tagsText = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var newImageData: Data?
    @State private var errorMessage: String?

    // MARK: Validation
    private var isNameValid: Bool { name.trimmingCharacters(in: .whitespaces).count >= 3 }
    private var isPresidentValid: Bool {
        president.isEmpty || president.count > 2
    }

    private var canSave: Bool { isNameValid && isPresidentValid }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Infos
                Section("Infos") {
                    TextField("Nom", text: $name)
                    if !isNameValid {
                        Text("Le nom doit contenir au moins 3 caractères.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    TextField("Description", text: $descriptionText)
                }

                // MARK: Image
                Section("Image") {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Text("Changer l’image")
                    }

                    if let data = newImageData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                    } else if let url = club.fullImageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img): img.resizable().scaledToFit().frame(height: 140)
                            default: Color.gray.opacity(0.2).frame(height: 140)
                            }
                        }
                    }
                }
                .onChange(of: selectedImage) { value in
                    Task {
                        newImageData = try? await value?.loadTransferable(type: Data.self)
                    }
                }

                // MARK: Président
                Section("Président") {
                    TextField("Id mongo du président", text: $president)
                        .autocorrectionDisabled()

                    if !isPresidentValid {
                        Text("L’ID doit contenir au moins 3 caractères.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // MARK: Tags
                Section("Tags") {
                    TextField("robotique, innovation", text: $tagsText)
                }

                if let errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
            }

            // MARK: Toolbar
            .navigationTitle("Modifier le club")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { Task { await save() } }
                        .disabled(!canSave)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onAppear(perform: preload)
        }
    }

    // MARK: Preload
    private func preload() {
        name = club.name
        descriptionText = club.description ?? ""
        president = club.president?.id ?? ""
        tagsText = club.tags.joined(separator: ", ")
    }

    // MARK: Save
    private func save() async {
        do {
            let tags = tagsText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }

            let updated = try await EspritAPI.shared.updateClub(
                token: token,
                id: club.id,
                name: name,
                description: descriptionText,
                president: president.isEmpty ? nil : president,
                tags: tags,
                image: newImageData
            )

            await MainActor.run {
                onSaved?(updated)
                dismiss()
            }

        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
