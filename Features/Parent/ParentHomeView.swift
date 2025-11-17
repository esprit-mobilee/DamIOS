//
//  ParentHomeView.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 8/11/2025.
//

import SwiftUI

struct ParentHomeView: View {
    let user: EspritUser     // ici c’est le parent connecté
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TopBar(title: "Espace Parent", userName: user.fullName) {
                        appState.logout()
                    }

                    HeroCard(
                        title: "Suivi de votre enfant",
                        subtitle: "Absences, résultats, annonces de l'école."
                    )

                    ActionGrid(role: .PARENT)

                    ParentStudentSummary()
                }
                .padding()
            }
            .background(Color.espritBgGray.ignoresSafeArea())
        }
    }
}

struct ParentStudentSummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Résumé de l'élève")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nom de l'élève")
                        .font(.subheadline)
                    Text("Classe : 4SIM4")
                        .font(.caption)
                        .foregroundColor(.espritTextGray)
                }
                Spacer()
                Text("Moyenne: 14.6")
                    .padding(6)
                    .background(Color.green.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack {
                StatChip(title: "Absences", value: "2")
                StatChip(title: "Retards", value: "1")
                StatChip(title: "Annonces", value: "3")
            }
        }
    }
}

struct StatChip: View {
    let title: String
    let value: String
    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.espritTextGray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)
    }
}
