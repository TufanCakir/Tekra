//
//  Theme.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct Theme: Codable, Identifiable {
    let name: String
    let background: Background
    let metal: Metal
    let energy: Energy
    let warning: String
    let text: TextColors
    let hud: HUD
    let buttons: Buttons
    let fx: FX
    let cornerRadius: CGFloat

    var id: String { name }  // 👈 stabile, menschliche, JSON-freie ID
}

struct Background: Codable {
    let top: String
    let bottom: String
    let chromeGradient: [String]
}

struct Metal: Codable {
    let highlight: String
    let light: String
    let base: String
    let dark: String
    let shadow: String
    let chromeGradient: [String]
    let bevelShadow: String
    let edgeGlow: String
}

struct Energy: Codable {
    let ice: EnergySet
    let fire: EnergySet
}

struct EnergySet: Codable {
    let core: String
    let glow: String
    let spark: String
}

struct TextColors: Codable {
    let primary: String
    let secondary: String
    let highlight: String
    let chromeGradient: [String]
}

struct HUD: Codable {
    let hp: HUDSet
    let exp: HUDSet
    let border: String
    let borderShadow: String
}

struct HUDSet: Codable {
    let core: String
    let glow: String
}

struct Buttons: Codable {
    let primaryGlow: String
    let dangerGlow: String
    let chromeEdge: String
    let chromeShadow: String
}

struct FX: Codable {
    let glowIntensity: CGFloat
    let metalShine: CGFloat
    let reflectionStrength: CGFloat
}

extension Theme {
    func chromeGradient() -> LinearGradient {
        LinearGradient(
            colors: metal.chromeGradient.map { Color(hex: $0) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
