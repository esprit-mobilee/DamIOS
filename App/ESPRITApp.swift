//
//  ESPRITApp.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 8/11/2025.
//
import SwiftUI

@main
struct ESPRITApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
