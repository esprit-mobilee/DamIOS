//
//  RootView.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 8/11/2025.
//
import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isCheckingAuth {
                // ⏳ Écran de chargement pendant la vérification du token
                SplashView()
            } else if let user = appState.currentUser {
                // 👤 Utilisateur authentifié → redirection selon le rôle
                RoleRouterView(user: user)
            } else {
                // 🔐 Non connecté → écran de connexion
                LoginView()
            }
        }
        .animation(.easeInOut, value: appState.isCheckingAuth)
        .animation(.easeInOut, value: appState.currentUser != nil)
    }
}
