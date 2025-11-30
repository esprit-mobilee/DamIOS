import Foundation

final class EspritAPI {

    static let shared = EspritAPI()
    private init() {}

    let client = APIClient.shared

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = try JSONEncoder().encode([
            "email": email,
            "password": password
        ])
        return try await client.request(
            "auth/login",
            method: "POST",
            body: body
        )
    }

    func getMe(token: String) async throws -> EspritUser {
        try await client.request("auth/me", token: token)
    }
    
    
}
