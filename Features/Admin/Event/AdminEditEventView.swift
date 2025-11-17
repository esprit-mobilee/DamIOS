import SwiftUI
import PhotosUI

struct AdminEditEventView: View {
    @Binding var event: Event          // ← BINDING POUR LE REFRESH AUTO
    let token: String

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var descriptionText: String
    @State private var date: Date
    @State private var location: String
    @State private var category: String
    @State private var image: UIImage?

    @State private var isLoading = false
    @State private var errorMessage: String?

    private var isTitleValid: Bool { title.trimmingCharacters(in: .whitespaces).count >= 3 }
    private var isDescriptionValid: Bool { descriptionText.isEmpty || descriptionText.count >= 5 }
    private var canSave: Bool { isTitleValid && isDescriptionValid }

    init(event: Binding<Event>, token: String) {
        self._event = event
        self.token = token

        let ev = event.wrappedValue

        _title = State(initialValue: ev.title)
        _descriptionText = State(initialValue: ev.description ?? "")
        _location = State(initialValue: ev.location ?? "")
        _category = State(initialValue: ev.category ?? "")

        let iso = ISO8601DateFormatter()
        _date = State(initialValue: iso.date(from: ev.date) ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {

                Section("Informations") {
                    TextField("Titre", text: $title)
                    if !isTitleValid {
                        Text("Le titre doit contenir au moins 3 caractères.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    TextField("Lieu", text: $location)
                    TextField("Catégorie", text: $category)
                }

                Section("Date") {
                    DatePicker("Date & heure", selection: $date)
                }

                Section("Description") {
                    TextEditor(text: $descriptionText)
                        .frame(height: 110)

                    if !isDescriptionValid {
                        Text("La description doit contenir au moins 5 caractères si renseignée.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section("Image") {
                    PhotosPicker("Changer l’affiche", selection: Binding(
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

                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(12)
                    }
                    else if let url = event.fullImageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img): img.resizable().scaledToFit()
                            default: Color.gray.opacity(0.2)
                            }
                        }
                        .frame(height: 120)
                        .cornerRadius(12)
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }

            .navigationTitle("Modifier l’événement")

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

        do {
            let iso = ISO8601DateFormatter().string(from: date)

            let updated = try await EspritAPI.shared.updateEvent(
                token: token,
                id: event.id,
                fields: [
                    "title": title,
                    "date": iso
                ],
                optionals: [
                    "description": descriptionText,
                    "location": location,
                    "category": category
                ],
                image: image
            )

            // REFRESH AUTOMATIQUE
            await MainActor.run {
                event = updated       // ← MET À JOUR LA SOURCE DE DONNÉES
                dismiss()
            }
        }
        catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
