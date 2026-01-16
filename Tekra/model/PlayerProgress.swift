//
//  PlayerProgress.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import Foundation
import SwiftData

@Model
final class PlayerProgress {
    // MARK: - Eindeutige Identität
    @Attribute(.unique) var id: UUID = UUID()

    // MARK: - Auswahl & Personalisierung
    var selectedFighterID: String = "tekra_core"
    var themeID: String = "tekra_silver_core"
    // MARK: - Unlocks
    var unlockedCardIDs: [String] = []

    // MARK: - Statistiken & Fortschritt
    var unlockedLevels: Int = 1
    var coins: Int = 0
    var highScore: Int = 0
    var lastPlayed: Date = Date.now
    var xp: Int = 0
    var level: Int = 1

    // MARK: - Theme Caching
    // Wir nutzen ein privates Feld, um das Theme nur einmal zu laden
    @Transient private var cachedTheme: Theme?

    init(selectedFighterID: String = "tekra_core", themeID: String = "theme") {
        self.id = UUID()
        self.selectedFighterID = selectedFighterID
        self.themeID = themeID
        self.unlockedLevels = 1
        self.coins = 0
        self.highScore = 0
        self.xp = 0
        self.level = 1
    }

    // Optimierte Computed Property
    @Transient var theme: Theme {
        if let cached = cachedTheme { return cached }
        let loaded = ThemeLoader.load(id: themeID)
        cachedTheme = loaded
        return loaded
    }

    func addXP(_ amount: Int) {
        guard amount > 0 else { return }
        xp += amount
        recalcLevel()
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
    }

    private func recalcLevel() {
        // Simple Level-Kurve: Level 1 = 0 XP, Level 2 = 100 XP, Level 3 = 250 XP, ...
        // Du kannst das später jederzeit anpassen.
        let thresholds: [Int] = [
            0, 100, 250, 450, 700, 1000, 1350, 1750, 2200, 2700,
        ]

        var newLevel = 1
        for (i, t) in thresholds.enumerated() {
            if xp >= t { newLevel = i + 1 }
        }
        level = newLevel

        // Beispiel: unlockedLevels an Level koppeln (optional)
        unlockedLevels = max(unlockedLevels, level)
    }

    func unlockCard(_ id: String) {
        guard !unlockedCardIDs.contains(id) else { return }
        unlockedCardIDs.append(id)
    }

    func isCardUnlocked(_ id: String) -> Bool {
        unlockedCardIDs.contains(id)
    }

    // Hilfsfunktion zum Wechseln des Themes
    func updateTheme(newID: String) {
        self.themeID = newID
        self.cachedTheme = nil  // Cache leeren, damit beim nächsten Zugriff neu geladen wird
    }
}
