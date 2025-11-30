//
//  RootView 2.swift
//  Esprit Ios
//
//  Created by mac air  on 21/11/2025.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isCheckingAuth {
                // Écran de chargement
                SplashScreen()
            }
            else if appState.currentUser == nil {
                // Pas connecté → Login
                LoginView()
            }
            else {
                // Connecté → Diriger selon le rôle
                RoleRouterView(user: appState.currentUser!)
            }
        }
    }
}