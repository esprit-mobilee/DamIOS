import Foundation
import Combine

@MainActor
final class MessagingViewModel: ObservableObject {

    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    // ---- LOAD MESSAGES ----
    func loadMessages(appState: AppState, otherUserId: String, token: String) async {

        guard let currentUserId = appState.currentUser?.id else { return }

        isLoading = true
        errorMessage = nil

        do {
            let data = try await EspritAPI.shared.getMessages(
                currentUserId: currentUserId,
                otherUserId: otherUserId,
                token: token
            )

            self.messages = data.map { msg in
                var m = msg
                m.isMine = (msg.senderId == currentUserId)
                return m
            }

        } catch {
            errorMessage = "Impossible de charger les messages."
        }

        isLoading = false
    }

    // ---- SEND MESSAGE ----
    func send(appState: AppState, to otherUserId: String, token: String) async {

        guard let currentUserId = appState.currentUser?.id else { return }
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let content = messageText
        messageText = ""

        do {
            let msg = try await EspritAPI.shared.sendMessage(
                senderId: currentUserId,
                receiverId: otherUserId,
                content: content,
                token: token
            )

            var local = msg
            local.isMine = true
            messages.append(local)

        } catch {
            errorMessage = "Erreur d’envoi."
        }
    }
}
