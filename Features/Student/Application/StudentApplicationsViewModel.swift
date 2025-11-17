import Foundation
import Combine

@MainActor
final class StudentApplicationsViewModel: ObservableObject {

    @Published var applications: [Application] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    // MARK: - Charger toutes mes candidatures (par user)
    func loadMyApplications(token: String, userId: String) async {
        isLoading = true
        error = nil

        do {
            let list = try await EspritAPI.shared.fetchApplications(token: token)
            self.applications = list.filter { $0.userId == userId }
        }
        catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Charger les candidatures d’un stage (admin)
    func loadForInternship(token: String, internshipId: String) async {
        isLoading = true
        error = nil

        do {
            let list = try await EspritAPI.shared.fetchApplications(token: token)
            self.applications = list.filter { $0.internshipId?.id == internshipId }
        }
        catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Créer une candidature (student)
    func createApplication(
        token: String,
        userId: String,
        internshipId: String,
        cvUrl: String,
        coverLetter: String?
    ) async -> Bool {

        do {
            _ = try await EspritAPI.shared.createApplication(
                token: token,
                userId: userId,
                internshipId: internshipId,
                cvUrl: cvUrl,
                coverLetter: coverLetter
            )
            return true
        }
        catch {
            print("❌ Erreur createApplication:", error.localizedDescription)
            return false
        }
    }

    // MARK: - Charger mes candidatures pour UN stage donné
    func loadApplicationsForStage(
        token: String,
        internshipId: String,
        userId: String
    ) async {

        self.isLoading = true
        self.error = nil
        self.applications = []

        do {
            let all = try await EspritAPI.shared.fetchApplications(token: token)

            // 🔥 CORRIGÉ : compare bien l'ID interne
            let filtered = all.filter {
                $0.userId == userId &&
                $0.internshipId?.id == internshipId
            }

            self.applications = filtered
        }
        catch {
            self.error = error.localizedDescription
        }

        self.isLoading = false
    }
    @MainActor
    func updateLocal(_ updated: Application) {
        if let index = applications.firstIndex(where: { $0.id == updated.id }) {
            applications[index] = updated
        }
    }

}
