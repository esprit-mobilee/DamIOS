import Foundation
import Combine
@MainActor
final class AnnouncementsViewModel: ObservableObject {

    @Published var announcements: [Announcement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // GET LIST
    func loadAnnouncements(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let list = try await EspritAPI.shared.getAnnouncements(token: token)
            self.announcements = list
        } catch {
            errorMessage = "Impossible de charger les annonces."
        }

        isLoading = false
    }

    // CREATE
    func createAnnouncement(
        title: String,
        content: String,
        audience: String,
        senderId: String,
        token: String
    ) async -> Bool {

        do {
            _ = try await EspritAPI.shared.createAnnouncement(
                title: title,
                content: content,
                audience: audience,
                senderId: senderId,
                token: token
            )
            return true
        }
        catch {
            errorMessage = "Erreur lors de la création."
            return false
        }
    }

    // UPDATE
    func updateAnnouncement(
        id: String,
        title: String,
        content: String,
        audience: String,
        senderId: String,
        token: String
    ) async -> Bool {

        do {
            let _ = try await EspritAPI.shared.updateAnnouncement(
                id: id,
                title: title,
                content: content,
                audience: audience,
                senderId: senderId,
                token: token
            )
            return true
        }
        catch {
            print("❌ Erreur update :", error)
            return false
        }
    }

    // DELETE
    func deleteAnnouncement(id: String, token: String) async {
        do {
            _ = try await EspritAPI.shared.deleteAnnouncement(id: id, token: token)
        } catch {
            errorMessage = "Erreur lors de la suppression."
        }
    }
}
