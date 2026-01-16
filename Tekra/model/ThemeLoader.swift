//
//  ThemeLoader.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import Foundation

enum ThemeLoader {

    // Das Notfall-Theme muss jetzt JEDES Feld deines neuen Modells bedienen
    private static var fallbackTheme: Theme {
        Theme(
            name: "Default",
            background: Background(
                top: "#1A1A1A",
                bottom: "#000000",
                chromeGradient: ["#2C3E50", "#000000"]
            ),
            metal: Metal(
                highlight: "#FFFFFF",
                light: "#D1D1D1",
                base: "#8E8E8E",
                dark: "#3A3A3A",
                shadow: "#000000",
                chromeGradient: ["#FFFFFF", "#8E8E8E", "#3A3A3A"],
                bevelShadow: "#000000",
                edgeGlow: "#FFFFFF"
            ),
            energy: Energy(
                ice: EnergySet(
                    core: "#A0E7FF",
                    glow: "#00A3FF",
                    spark: "#FFFFFF"
                ),
                fire: EnergySet(
                    core: "#FFCC00",
                    glow: "#FF4D00",
                    spark: "#FFFFFF"
                )
            ),
            warning: "#FF0000",
            text: TextColors(
                primary: "#FFFFFF",
                secondary: "#AAAAAA",
                highlight: "#FFCC00",
                chromeGradient: ["#FFFFFF", "#AAAAAA"]
            ),
            hud: HUD(
                hp: HUDSet(core: "#FF3B30", glow: "#FF0000"),
                exp: HUDSet(core: "#4CD964", glow: "#00FF00"),
                border: "#FFFFFF",
                borderShadow: "#000000"
            ),
            buttons: Buttons(
                primaryGlow: "#007AFF",
                dangerGlow: "#FF3B30",
                chromeEdge: "#FFFFFF",
                chromeShadow: "#000000"
            ),
            fx: FX(
                glowIntensity: 0.8,
                metalShine: 1.0,
                reflectionStrength: 0.5
            ),
            cornerRadius: 18
        )
    }

    static func load(id: String? = nil) -> Theme {
        let fileName = id ?? "theme"

        guard
            let url = Bundle.main.url(
                forResource: fileName,
                withExtension: "json"
            )
        else {
            return fallbackTheme
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Theme.self, from: data)
        } catch {
            print("❌ Decode Error: \(error)")
            return fallbackTheme
        }
    }
}
