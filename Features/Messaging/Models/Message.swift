import Foundation

public struct Message: Codable, Identifiable {
    public let id: String
    public let senderId: String
    public let receiverId: String
    public let content: String
    public let createdAt: String

    // IMPORTANT : isMine doit être VAR + public
    public var isMine: Bool

    // Décodage JSON
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case senderId
        case receiverId
        case content
        case createdAt
        case isMine
    }

    // Initialisation personnalisée pour pouvoir le modifier après
    public init(
        id: String,
        senderId: String,
        receiverId: String,
        content: String,
        createdAt: String,
        isMine: Bool = false
    ) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
        self.createdAt = createdAt
        self.isMine = isMine
    }
}
