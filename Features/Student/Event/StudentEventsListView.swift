//
//  StudentEventsListView.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 15/11/2025.
//

import SwiftUI

struct StudentEventsListView: View {
    @EnvironmentObject var appState: AppState
    @State private var events: [Event] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 22) {
                    ForEach(events) { event in
                        NavigationLink {
                            StudentEventDetailView(event: event)
                        } label: {
                            eventCard(event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .navigationTitle("Événements")
            .task { await loadEvents() }
        }
    }

    private func loadEvents() async {
        guard let token = appState.token else { return }
        do {
            events = try await EspritAPI.shared.fetchEvents(token: token)
        } catch {
            print("❌ Erreur load events:", error)
        }
        isLoading = false
    }
    @ViewBuilder
    func eventCard(_ event: Event) -> some View {
        HStack(spacing: 16) {

            // IMAGE
            AsyncImage(url: event.fullImageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()

                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                        .foregroundColor(.gray.opacity(0.4))

                default:
                    ProgressView()
                }
            }
            .frame(width: 110, height: 110)
            .background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18))


            // TEXTES
            VStack(alignment: .leading, spacing: 8) {

                Text(event.title)
                    .font(.title3)
                    .bold()

                if let loc = event.location {
                    Label(loc, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                }

                Label(formatDate(event.date), systemImage: "calendar")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.white)
                .shadow(color: .black.opacity(0.07), radius: 8, y: 4)
        )
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return iso }

        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short

        return f.string(from: date)
    }

}

