//
//  FighterRegistry.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

@MainActor
enum FighterRegistry {

    // MARK: - Speicher
    private(set) static var currentRaidBosses: [String: RaidBoss] = [:]
    private(set) static var currentArcadeWaves: [ArcadeWave] = []
    private(set) static var playableCharacters: [Fighter] = []

    /// ✅ Zentrale Enemy-Liste (Story / Arcade / Raid)
    private(set) static var allEnemies: [Fighter] = []

    // MARK: - Ladevorgang
    static func loadAll() {

        // 1. Raid Bosse
        let raids = RaidLoader.load()
        currentRaidBosses = Dictionary(
            uniqueKeysWithValues: raids.map { ($0.id, $0) }
        )

        // 2. Arcade Waves
        currentArcadeWaves = ArcadeLoader.load()

        // 3. Spielbare Charaktere
        playableCharacters = FighterLoader.load(file: "players")

        // 4. Enemy-Registry bauen
        buildEnemyRegistry()

        print(
            """
            ✅ Registry synchronisiert
            👤 Helden: \(playableCharacters.count)
            👹 Enemies: \(allEnemies.count)
            🧠 Raids: \(currentRaidBosses.count)
            🕹 Arcade Waves: \(currentArcadeWaves.count)
            """
        )
    }

    // MARK: - Enemy Registry Builder

    private static func buildEnemyRegistry() {

        var enemies: [Fighter] = []

        // A) Arcade-Gegner
        for wave in currentArcadeWaves {
            for round in wave.rounds {
                for arcadeEnemy in round {
                    enemies.append(arcadeEnemy.toFighter())
                }
            }
        }

        // B) Raid-Bosse
        for boss in currentRaidBosses.values {
            enemies.append(boss.toFighter())
        }

        // C) Duplikate entfernen
        allEnemies = Array(
            Dictionary(grouping: enemies, by: { $0.id })
                .values
                .compactMap { $0.first }
        )
    }

    // MARK: - Lookups (Story / Combat)

    /// Gegner für Story / Arcade / Raid
    static func enemy(id: String) -> Fighter? {
        if allEnemies.isEmpty { loadAll() }
        return allEnemies.first(where: { $0.id == id })
    }

    /// Spielbarer Charakter
    static func player(id: String) -> Fighter? {
        if playableCharacters.isEmpty { loadAll() }
        return playableCharacters.first(where: { $0.id == id })
    }

    /// Raid-Boss
    static func raidBoss(id: String) -> RaidBoss? {
        if currentRaidBosses.isEmpty { loadAll() }
        return currentRaidBosses[id]
    }
}
