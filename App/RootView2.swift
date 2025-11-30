import SwiftUI

struct RootView2: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainHomeView()   // ← AFFICHER LE HOME CORRECTEMENT
            } else {
                LoginView()
            }
        }
    }
}
