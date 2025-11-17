import SwiftUI
import PhotosUI

struct AdminEditInternshipView: View {
    let token: String
    let offer: InternshipOffer
    var onSaved: ((InternshipOffer) -> Void)?
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var company = ""
    @State private var descriptionText = ""
    @State private var location = ""
    @State private var duration = ""
    @State private var salary = ""
    @State private var pickedImage: UIImage?
    @State private var errorMessage: String?
    @State private var isLoading = false

    // MARK: VALIDATION
    private var isTitleValid: Bool { title.count >= 3 }
    private var isCompanyValid: Bool { company.count >= 2 }
    private var isDurationValid: Bool { Int(duration) != nil && Int(duration)! > 0 }
    private var isSalaryValid: Bool { salary.isEmpty || Int(salary) != nil }
    private var isDescriptionValid: Bool { descriptionText.count >= 5 }

    private var canSave: Bool {
        isTitleValid && isCompanyValid && isDurationValid && isSalaryValid && isDescriptionValid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Informations") {
                    TextField("Titre", text: $title)
                    if !isTitleValid { Text("≥ 3 caractères").foregroundColor(.red).font(.caption) }

                    TextField("Entreprise", text: $company)
                    if !isCompanyValid { Text("≥ 2 caractères").foregroundColor(.red).font(.caption) }

                    TextField("Lieu", text: $location)

                    TextField("Durée (semaines)", text: $duration)
                        .keyboardType(.numberPad)
                    if !isDurationValid { Text("Durée non valide").foregroundColor(.red).font(.caption) }

                    TextField("Salaire", text: $salary)
                        .keyboardType(.numberPad)
                    if !isSalaryValid { Text("Nombre uniquement").foregroundColor(.red).font(.caption) }
                }

                Section("Description") {
                    TextEditor(text: $descriptionText)
                        .frame(height: 100)
                    if !isDescriptionValid {
                        Text("≥ 5 caractères")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section("Logo") {
                    PhotosPicker("Changer logo", selection: Binding(
                        get: { nil },
                        set: { item in
                            if let item {
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let img = UIImage(data: data) {
                                        await MainActor.run { pickedImage = img }
                                    }
                                }
                            }
                        }
                    ))

                    if let img = pickedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                    } else if let url = offer.logoFullURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFit().frame(height: 80)
                            default:
                                Color.gray.opacity(0.2).frame(height: 80)
                            }
                        }
                    }
                }

                if let err = errorMessage {
                    Text(err).foregroundColor(.red)
                }
            }

            .navigationTitle("Modifier le stage")

            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isLoading ? "..." : "Sauvegarder") {
                        Task { await save() }
                    }
                    .disabled(!canSave)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onAppear(perform: preload)
        }
    }

    private func preload() {
        title = offer.title
        company = offer.company
        descriptionText = offer.description
        location = offer.location ?? ""
        duration = "\(offer.duration)"
        salary = offer.salary != nil ? "\(offer.salary!)" : ""
    }

    private func save() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let dto = UpdateInternshipOfferDto(
                title: title,
                company: company,
                description: descriptionText,
                location: location.isEmpty ? nil : location,
                duration: Int(duration) ?? 0,
                salary: Int(salary)
            )

            // ❗ envoyer l’image sous "logo"
            let updated = try await EspritAPI.shared.updateInternshipOfferByTitle(
                token: token,
                title: offer.title,
                dto: dto,
                logo: pickedImage           // ❗ pas image: mais logo:
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
