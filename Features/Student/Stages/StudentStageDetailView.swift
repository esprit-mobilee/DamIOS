//
//  StudentStageDetailView.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 13/11/2025.
//

import SwiftUI

struct StudentStageDetailView: View {
    let offer: InternshipOffer

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // MARK: - Pour ouvrir la fenêtre de formulaire
    @State private var showApplySheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - Image grande
                AsyncImage(url: offer.logoFullURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .padding(40)
                            .foregroundColor(.gray.opacity(0.4))
                    default:
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // MARK: - Titre + Entreprise
                VStack(alignment: .leading, spacing: 8) {
                    Text(offer.title)
                        .font(.title2)
                        .bold()

                    Text(offer.company)
                        .font(.headline)
                        .foregroundColor(.gray)

                    if let loc = offer.location {
                        Label(loc, systemImage: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                Divider()

                // MARK: - Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)

                    Text(offer.description)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                Divider()

                // MARK: - Infos
                VStack(alignment: .leading, spacing: 10) {
                    Label("Durée : \(offer.duration) semaines", systemImage: "clock")

                    if let salary = offer.salary {
                        Label("Salaire : \(salary) TND", systemImage: "banknote")
                    }
                }
                .foregroundColor(.gray)
                .padding(.horizontal)

                // MARK: - Bouton POSTULER → Ouvre le formulaire
                Button {
                    showApplySheet = true
                } label: {
                    Text("Postuler")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.espritRedPrimary)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            NavigationLink {
                StudentMyApplicationsForStageView(internshipId: offer.id)
                    .environmentObject(appState)
            } label: {
                Text("Voir mes candidatures pour ce stage")
            }
            .padding(.vertical)
        }
        .navigationTitle("Stage")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Fenêtre (sheet) pour remplir la candidature
        .sheet(isPresented: $showApplySheet) {
            ApplyForInternshipView(internshipId: offer.id)
                .environmentObject(appState)
        }
    }
}

