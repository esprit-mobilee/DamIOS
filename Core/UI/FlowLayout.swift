//
//  FlowLayout.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 14/11/2025.
//

import SwiftUI

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    
    let items: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        VStack {
            GeometryReader { geo in
                generateContent(in: geo)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .alignmentGuide(.leading) { d in
                        if width + d.width > geo.size.width {
                            width = 0
                            height -= d.height + spacing
                        }

                        let result = width
                        width -= d.width + spacing
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last {
                            height = 0
                        }
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

