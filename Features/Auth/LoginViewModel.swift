import SwiftUI
import Combine 
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var identifier = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    func login(appState: AppState) async {
        isLoading = true
        errorMessage = nil

        do {
            // 1. login → token
            let login = try await EspritAPI.shared.login(identifiant: identifier, password: password)

            // 2. getMe avec le token pour avoir le vrai nom + rôle
            var user: EspritUser
            do {
                user = try await EspritAPI.shared.getMe(token: login.accessToken)
            } catch {
                print("❌ /me a échoué, on garde le user du login ou un défaut")
                user = login.user ?? EspritUser(fullName: "Utilisateur ESPRIT")
            }

            // 3. on enregistre
            appState.setSession(token: login.accessToken, user: user)

        } catch let apiError as APIError {
            switch apiError {
            case .server(let status, let body):
                errorMessage = "Serveur (\(status)) : \(body)"
            case .invalidResponse:
                errorMessage = "Réponse invalide du serveur."
            @unknown default:
                errorMessage = "Erreur API inconnue."
            }
        } catch {
            errorMessage = "Erreur inconnue: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
