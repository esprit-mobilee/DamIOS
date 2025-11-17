//
//  TopBar.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 8/11/2025.
//

import SwiftUI

struct TopBar: View {
    let title: String
    let userName: String
    let onLogout: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.espritHeaderBlack)
                Text(userName)
                    .font(.subheadline)
                    .foregroundColor(.espritTextGray)
            }
            Spacer()
            Button(action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title2)
                    .foregroundColor(.espritRedPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
}
