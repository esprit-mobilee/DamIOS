import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {

    static let shared = AppState()

    @Published var currentUser: EspritUser?
    @Published var token: String?
    @Published var isAuthenticated: Bool = false

    private init() {}

    // SET SESSION après login
    func setSession(token: String, user: EspritUser) {
        self.token = token
        self.currentUser = user
        self.isAuthenticated = true
    }

    // CLEAR SESSION pour logout
    func clearSession() {
        self.token = nil
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
