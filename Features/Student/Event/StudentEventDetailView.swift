//
//  StudentEventDetailView.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 15/11/2025.
//
import SwiftUI

struct StudentEventDetailView: View {
    let event: Event

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - EVENT IMAGE
                AsyncImage(url: event.fullImageURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .foregroundColor(.gray.opacity(0.4))
                    default:
                        ProgressView()
                            .frame(height: 100)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // MARK: - TITLE + INFO
                VStack(alignment: .leading, spacing: 12) {

                    Text(event.title)
                        .font(.title.bold())

                    // LOCATION
                    if let loc = event.location, !loc.isEmpty {
                        Label(loc, systemImage: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }

                    // DATE
                    Label(formatDate(event.date), systemImage: "calendar")
                        .foregroundColor(.red)
                        .font(.subheadline)

                    // CATEGORY
                    if let cat = event.category, !cat.isEmpty {
                        Label(cat, systemImage: "tag")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)

                Divider()

                // MARK: - DESCRIPTION
                if let desc = event.description, !desc.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)

                        Text(desc)
                            .foregroundColor(.gray)
                            .font(.body)
                    }
                    .padding(.horizontal)
                }

                Divider()

          
                // MARK: - ORGANIZER
                if let organizer = event.organizerId {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Organisé par")
                            .font(.headline)

                        switch organizer {

                        case .id(let id):
                            // organiserId était juste un String
                            Text("ID : \(id)")
                                .foregroundColor(.gray)

                        case .user(let user):
                            // organiserId était un object EventOrganizer
                            if let first = user.firstName, let last = user.lastName {
                                Text("\(first) \(last)")
                                    .foregroundColor(.gray)
                            }
                            if let email = user.email {
                                Text(email)
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                        }
                    }
                    .padding(.horizontal)
                }


                Spacer().frame(height: 30)
            }
            .padding(.vertical)
        }
        .navigationTitle("Événement")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - FORMAT DATE
    private func formatDate(_ iso: String) -> String {
        let isoF = ISO8601DateFormatter()
        guard let d = isoF.date(from: iso) else { return iso }

        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short

        return f.string(from: d)
    }
}

