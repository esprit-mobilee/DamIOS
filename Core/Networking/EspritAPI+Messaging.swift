import Foundation

extension EspritAPI {

    // ----- GET CONVERSATIONS -----
    func getConversations(userId: String, token: String) async throws -> [Conversation] {
        return try await client.request(
            "messages/conversations/\(userId)",
            token: token
        )
    }

    // ----- GET MESSAGES -----
    func getMessages(currentUserId: String, otherUserId: String, token: String) async throws -> [Message] {
        return try await client.request(
            "messages/conversation/\(currentUserId)/\(otherUserId)",
            token: token
        )
    }

    // ----- SEND MESSAGE -----
    func sendMessage(senderId: String, receiverId: String, content: String, token: String) async throws -> Message {

        let body = try JSONEncoder().encode([
            "senderId": senderId,
            "content": content
        ])

        return try await client.request(
            "messages/\(receiverId)",
            method: "POST",
            body: body,
            token: token
        )
    }
}
