import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func login(appState: AppState) async {
        isLoading = true
        errorMessage = nil

        do {
            let auth = try await EspritAPI.shared.login(
                email: email,
                password: password
            )

            let user = auth.toUser()
            appState.setSession(token: auth.accessToken, user: user)

        } catch let apiError as APIError {
            switch apiError {
            case .server(let status, let body):
                errorMessage = "Serveur (\(status)) : \(body)"
            case .invalidResponse:
                errorMessage = "Réponse invalide du serveur."
            default:
                errorMessage = "Erreur API inconnue."
            }
        } catch {
            errorMessage = "Erreur inconnue : \(error.localizedDescription)"
        }

        isLoading = false
    }
}
