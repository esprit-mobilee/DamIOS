import Foundation
import Combine

@MainActor
final class ConversationsViewModel: ObservableObject {

    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadConversations(token: String, currentUserId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let data = try await EspritAPI.shared.getConversations(
                userId: currentUserId,
                token: token
            )
            self.conversations = data
        } catch {
            print("Erreur getConversations:", error)
            errorMessage = "Impossible de charger les conversations."
        }

        isLoading = false
    }
}
