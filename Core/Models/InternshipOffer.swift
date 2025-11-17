import Foundation

struct InternshipOffer: Identifiable, Codable {
    let _id: String
    var id: String { _id }

    var title: String
    var company: String
    var description: String
    var location: String?
    var duration: Int
    var salary: Int?
    var logoUrl: String?
}

// MARK: - Extension pour URL complète du logo
extension InternshipOffer {
    var logoFullURL: URL? {
        guard let url = logoUrl else { return nil }
        return URL(string: "http://localhost:3000\(url)")
    }
}
