import Foundation

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let userId: String
    let role: String
    let email: String
    
    func toUser() -> EspritUser {
        EspritUser(id: userId, email: email, role: role)
    }
}
