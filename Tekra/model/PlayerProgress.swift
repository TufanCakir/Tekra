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

    @Attribute(.unique) var id: UUID

    // MARK: - Auswahl
    var selectedFighterID: String

    // MARK: - Unlocks / Progress
    var unlockedCharacters: [String]
    var completedStages: [String]
    var unlockedCardIDs: [String]
    var playerLevel: Int {
        max(1, xp / 100 + 1)
    }
    var unlockedLevels: Int
    var coins: Int
    var highScore: Int
    var lastPlayed: Date
    var xp: Int
    var level: Int

    var themeID: String

    // MARK: - Theme Cache
    @Transient private var cachedTheme: Theme?

    // ✅ ALLE Default-Werte HIER
    init(
        selectedFighterID: String = "tekra_core",
        themeID: String = "tekra_silver_core"
    ) {
        self.id = UUID()

        self.selectedFighterID = selectedFighterID
        self.themeID = themeID

        self.unlockedCharacters = ["tekra_core"]  // 👈 Start-Held
        self.completedStages = []
        self.unlockedCardIDs = []

        self.unlockedLevels = 1
        self.coins = 0
        self.highScore = 0
        self.xp = 0
        self.level = 1
        self.lastPlayed = Date()
    }

    // MARK: - Unlock Logic

    func unlockCharacter(_ id: String) {
        guard !unlockedCharacters.contains(id) else { return }
        unlockedCharacters.append(id)
    }

    func isCharacterUnlocked(_ id: String) -> Bool {
        unlockedCharacters.contains(id)
    }

    func completeStage(_ stageID: String) {
        guard !completedStages.contains(stageID) else { return }
        completedStages.append(stageID)
    }

    // MARK: - XP / Level

    func addXP(_ amount: Int) {
        guard amount > 0 else { return }
        xp += amount
        lastPlayed = Date()
        recalcLevel()
    }

    // MARK: - Coins

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
        lastPlayed = Date()
    }

    private func recalcLevel() {
        let thresholds = [0, 100, 250, 450, 700, 1000]
        level =
            thresholds.enumerated().last { xp >= $0.element }?.offset.advanced(
                by: 1
            ) ?? 1
        unlockedLevels = max(unlockedLevels, level)
    }

    // MARK: - Theme

    @Transient var theme: Theme {
        if let cachedTheme { return cachedTheme }
        let t = ThemeLoader.load(id: themeID)
        cachedTheme = t
        return t
    }

    func updateTheme(newID: String) {
        themeID = newID
        cachedTheme = nil
    }
}
