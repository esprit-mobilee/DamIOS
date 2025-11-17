// UI/Theme/EspritColors.swift
import SwiftUI

extension Color {
    static let espritRedPrimary = Color(hex: "#D9352A")
    static let espritRedDark = Color(hex: "#C22B20")
    static let espritHeaderBlack = Color(hex: "#1F1F1F")
    static let espritBgGray = Color(hex: "#F2F2F2")
    static let espritTextGray = Color(hex: "#6B6B6B")
}

extension Color {
    init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        h = h.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}
