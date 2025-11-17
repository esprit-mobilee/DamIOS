import Foundation

struct Event: Identifiable, Codable {

    let _id: String
    var id: String { _id }

    let title: String
    let description: String?
    let date: String
    let location: String?
    let category: String?
    let imageUrl: String?

    let organizerId: OrganizerField?   // 🔥 String OU Object

    let createdAt: String?
    let updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case _id = "_id"
        case title
        case description
        case date
        case location
        case category
        case imageUrl
        case organizerId
        case createdAt
        case updatedAt
        case v = "__v"
    }
}

// Organizer simple quand c'est un object
struct EventOrganizer: Codable {
    let firstName: String?
    let lastName: String?
    let email: String?
}

// 🔥 Méga fix — organizerId peut être soit "String" soit "Object"
enum OrganizerField: Codable {
    case id(String)
    case user(EventOrganizer)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let id = try? container.decode(String.self) {
            self = .id(id)
            return
        }

        if let user = try? container.decode(EventOrganizer.self) {
            self = .user(user)
            return
        }

        throw DecodingError.typeMismatch(
            OrganizerField.self,
            .init(codingPath: decoder.codingPath,
                  debugDescription: "organizerId is neither a String nor an EventOrganizer")
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .id(let string):
            try container.encode(string)
        case .user(let user):
            try container.encode(user)
        }
    }
}

// URL complète pour l’affiche
extension Event {
    var fullImageURL: URL? {
        guard let imageUrl else { return nil }
        return URL(string: "http://localhost:3000\(imageUrl)")
    }
}
