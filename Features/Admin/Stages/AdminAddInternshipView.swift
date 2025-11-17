import SwiftUI
import PhotosUI

struct AdminAddInternshipView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var onSaved: (InternshipOffer) -> Void

    @State private var title = ""
    @State private var company = ""
    @State private var location = ""
    @State private var descriptionText = ""
    @State private var duration = ""
    @State private var salary = ""
    @State private var logo: UIImage?

    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - VALIDATION
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
                    if !isTitleValid {
                        Text("Le titre doit contenir au moins 3 caractères.")
                            .font(.caption).foregroundColor(.red)
                    }

                    TextField("Entreprise", text: $company)
                    if !isCompanyValid {
                        Text("Le nom de l’entreprise doit contenir au moins 2 caractères.")
                            .font(.caption).foregroundColor(.red)
                    }

                    TextField("Lieu", text: $location)

                    TextField("Durée (en semaines)", text: $duration)
                        .keyboardType(.numberPad)
                    if !isDurationValid {
                        Text("La durée doit être un nombre strictement positif.")
                            .font(.caption).foregroundColor(.red)
                    }

                    TextField("Salaire", text: $salary)
                        .keyboardType(.numberPad)
                    if !isSalaryValid {
                        Text("Le salaire doit être un nombre.")
                            .font(.caption).foregroundColor(.red)
                    }
                }

                Section("Description") {
                    TextEditor(text: $descriptionText)
                        .frame(height: 100)
                    if !isDescriptionValid {
                        Text("La description doit contenir au moins 5 caractères.")
                            .font(.caption).foregroundColor(.red)
                    }
                }

                // MARK: LOGO
                Section("Logo") {
                    PhotosPicker("Choisir un logo", selection: Binding(
                        get: { nil },
                        set: { item in
                            if let item {
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let img = UIImage(data: data) {
                                        await MainActor.run { self.logo = img }
                                    }
                                }
                            }
                        }
                    ))

                    if let logo {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(10)
                    }
                }

                if let errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
            }

            .navigationTitle("Ajouter un stage")

            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isLoading ? "..." : "Enregistrer") {
                        Task { await save() }
                    }
                    .disabled(!canSave || isLoading)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }

    private func save() async {
        guard let token = appState.token else {
            errorMessage = "Admin déconnecté."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let created = try await EspritAPI.shared.createInternshipOffer(
                token: token,
                title: title,
                company: company,
                description: descriptionText,
                location: location.isEmpty ? nil : location,
                duration: Int(duration) ?? 0,
                salary: Int(salary),
                logo: logo
            )

            await MainActor.run {
                onSaved(created)
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erreur : \(error.localizedDescription)"
            }
        }
    }
}
