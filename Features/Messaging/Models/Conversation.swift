import Foundation

struct Conversation: Identifiable, Codable {
    let id = UUID().uuidString     // généré côté iOS pour Identifiable

    let userId: String
    let userName: String
    let lastMessage: String
    let lastMessageTime: String
    let unreadCount: Int

    // Pas de userRole → il n'existe pas dans l’API
}
