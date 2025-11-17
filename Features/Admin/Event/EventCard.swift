//
//  EventCard.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 15/11/2025.
//

import SwiftUI

struct EventCard: View {
    let event: Event

    var body: some View {
        HStack(spacing: 16) {

            AsyncImage(url: event.fullImageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure(_):
                    Image(systemName: "calendar")
                        .resizable().scaledToFit()
                        .padding(20)
                        .foregroundColor(.gray.opacity(0.4))
                default:
                    ProgressView()
                }
            }
            .frame(width: 110, height: 110)
            .background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.title3).bold()
                if let loc = event.location {
                    Label(loc, systemImage: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                Text(formatDate(event.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.white)
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
        )
    }

    private func formatDate(_ iso: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: iso) else { return iso }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}
