import SwiftUI

@main
struct ESPRITIosApp: App {

    @StateObject var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            RootView2()
                .environmentObject(appState)
        }
    }
}
