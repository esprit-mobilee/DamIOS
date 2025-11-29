//
//  SplashScreen.swift
//  Esprit Ios
//
//  Created by mac air  on 21/11/2025.
//

import SwiftUI

struct SplashScreen: View {
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) {
                Image("esprit_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("ESPRIT App")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(red: 0.85, green: 0.16, blue: 0.12))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}
