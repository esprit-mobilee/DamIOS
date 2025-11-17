import Foundation

struct Club: Identifiable, Codable {
    let id: String
    let name: String
    let description: String?
    let president: ClubUser?
    let members: [ClubUser]
    let tags: [String]
    let imageUrl: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case president
        case members
        case tags
        case imageUrl
        case createdAt
        case updatedAt
    }

    /// URL complète pour charger l'image depuis NestJS
    var fullImageURL: URL? {
        guard let imageUrl else { return nil }
        return URL(string: "http://localhost:3000\(imageUrl)")
    }
}

struct ClubUser: Identifiable, Codable {
    let id: String
    let identifiant: String?
    let firstName: String?
    let lastName: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case identifiant
        case firstName
        case lastName
        case email
    }
}
