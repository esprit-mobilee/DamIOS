//
//  Side.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 9/11/2025.
//

import SwiftUI

struct SideMenuView: View {
    let user: EspritUser
    let onSelect: (MenuItem) -> Void
    let onLogout: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // header rouge
            VStack(alignment: .leading, spacing: 6) {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )

                Text(user.fullName)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(user.roles.first?.rawValue ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                // si tu as la classe (ex 4SIM4) tu peux l’ajouter dans EspritUser plus tard
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(#colorLiteral(red: 0.85, green: 0.16, blue: 0.12, alpha: 1)))

            // items
            VStack(alignment: .leading, spacing: 0) {
                SideMenuRow(icon: "person.fill", title: "Profil") { onSelect(.profil) }
                SideMenuRow(icon: "envelope.fill", title: "Messages") { onSelect(.messages) }
                SideMenuRow(icon: "calendar", title: "Emploi du temps") { onSelect(.timetable) }
            }

            Spacer()

            // logout
            SideMenuRow(icon: "rectangle.portrait.and.arrow.right", title: "Se déconnecter", tint: .red) {
                onLogout()
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: 250, alignment: .leading)
        .background(Color(.systemGray6))
    }
}

enum MenuItem {
    case profil
    case messages
    case timetable
}

struct SideMenuRow: View {
    let icon: String
    let title: String
    var tint: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                Spacer()
            }
            .foregroundColor(tint)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
