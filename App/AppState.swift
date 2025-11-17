import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isCheckingAuth = true
    @Published var currentUser: EspritUser? = nil
    @Published var token: String? = nil

    init() {
        Task { await checkExistingSession() }
    }

    func checkExistingSession() async {
        if let stored = readToken() {
            do {
                let me = try await EspritAPI.shared.getMe(token: stored)
                self.token = stored
                self.currentUser = me
            } catch {
                deleteToken()
            }
        }
        self.isCheckingAuth = false
    }

    func setSession(token: String, user: EspritUser) {
        saveToken(token)
        self.token = token
        self.currentUser = user
    }

    func logout() {
        deleteToken()
        self.token = nil
        self.currentUser = nil
    }
}
