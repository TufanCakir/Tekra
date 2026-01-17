//
//  FighterRegistry.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//
import Foundation

@MainActor
enum FighterRegistry {

    // MARK: - State
    private static var isLoaded = false  // 🔐 DAS FEHLTE

    // MARK: - Speicher
    private(set) static var currentRaidBosses: [String: RaidBoss] = [:]
    private(set) static var currentArcadeWaves: [ArcadeWave] = []
    private(set) static var playableCharacters: [Fighter] = []
    private(set) static var allEnemies: [Fighter] = []

    // MARK: - Load
    static func loadAll() {
        guard !isLoaded else {
            print("ℹ️ FighterRegistry: already loaded – skip")
            return
        }

        isLoaded = true
        print("🔄 FighterRegistry: Initial Load")

        // 1. Raid Bosse
        let raids = RaidLoader.load()
        currentRaidBosses = Dictionary(
            uniqueKeysWithValues: raids.map { ($0.id, $0) }
        )

        // 2. Arcade Waves
        currentArcadeWaves = ArcadeLoader.load()

        // 3. Spieler
        playableCharacters = FighterLoader.load(file: "players")

        // 4. Enemy-Registry
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

        // Arcade Enemies registrieren
        for wave in currentArcadeWaves {
            for round in wave.rounds {
                for enemy in round {
                    enemies.append(enemy.fighter)
                }
            }
        }

        // Raid
        for boss in currentRaidBosses.values {
            enemies.append(boss.makeFighter())
        }

        // Duplikate entfernen
        allEnemies = Array(
            Dictionary(grouping: enemies, by: { $0.id })
                .values
                .compactMap { $0.first }
        )
    }

    // MARK: - Lookups
    static func enemy(id: String) -> Fighter? {
        loadAll()
        return allEnemies.first(where: { $0.id == id })
    }

    static func player(id: String) -> Fighter? {
        loadAll()
        return playableCharacters.first(where: { $0.id == id })
    }

    static func raidBoss(id: String) -> RaidBoss? {
        loadAll()
        return currentRaidBosses[id]
    }
}
