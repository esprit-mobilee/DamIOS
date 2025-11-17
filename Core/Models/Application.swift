import Foundation

struct Application: Identifiable, Codable {
    let id: String
    let userId: String
    let internshipId: InternshipOffer?   // 🔥 Correction importante
    let cvUrl: String
    let coverLetter: String?
    let aiScore: Int?
    let status: String
    let submittedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case internshipId
        case cvUrl
        case coverLetter
        case aiScore
        case status
        case submittedAt
    }
}
