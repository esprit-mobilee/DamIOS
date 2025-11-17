//
//  StudentClubDetailView.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 14/11/2025.
//

import SwiftUI

struct StudentClubDetailView: View {

    let club: Club

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // --- IMAGE ---
                AsyncImage(url: club.fullImageURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFit()
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable().scaledToFit()
                            .padding(40)
                            .foregroundColor(.gray.opacity(0.4))
                    default:
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // --- TEXTE ---
                VStack(alignment: .leading, spacing: 12) {

                    Text(club.name)
                        .font(.title2.bold())

                    if let desc = club.description {
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.gray)
                    }

                    Divider()

                    if let p = club.president {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Président")
                                .font(.headline)
                            Text("\(p.firstName ?? "") \(p.lastName ?? "")")
                                .foregroundColor(.red)
                        }
                    }

                    Divider()

                    // ------------------------
                    //     TAGS (FIXED)
                    // ------------------------
                    if !club.tags.isEmpty {    // <- corrigé : tags n'est pas optional
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tags")
                                .font(.headline)

                            WrapView(items: club.tags) { tag in
                                Text(tag)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(club.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// -----------------------------------------
//         WRAP VIEW (inchangé)
// -----------------------------------------

struct WrapView<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Hashable {

    let items: Data
    let content: (Data.Element) -> Content

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        VStack {
            GeometryReader { geo in
                self.generateContent(in: geo)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding(4)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > g.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        width -= d.width
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last { height = 0 }
                        return result
                    }
            }
        }
        .background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    totalHeight = geo.size.height
                }
                return Color.clear
            }
        )
    }
}
