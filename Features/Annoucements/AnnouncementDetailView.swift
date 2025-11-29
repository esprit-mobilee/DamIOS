//
//  AnnouncementDetailView.swift
//  Esprit Ios
//
//  Created by mac air  on 23/11/2025.
//

import SwiftUI

struct AnnouncementDetailView: View {
    let item: Announcement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(item.title)
                    .font(.title2)
                    .bold()

                Text(item.content)
                    .font(.body)
                    .foregroundColor(.gray)

                Divider()

                HStack {
                    Text("Audience :")
                        .fontWeight(.medium)
                    Text(item.audience ?? "Tous")
                }
                .font(.subheadline)

                Text("Publié le : \(formatDate(item.createdAt))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
    }

    func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let df = DateFormatter()
            df.dateStyle = .medium
            return df.string(from: date)
        }
        return iso
    }
}
