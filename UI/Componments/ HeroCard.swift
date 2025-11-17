//
//   HeroCard.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 8/11/2025.
//

import SwiftUI

struct HeroCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.espritRedPrimary)
                .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 140)
    }
}
