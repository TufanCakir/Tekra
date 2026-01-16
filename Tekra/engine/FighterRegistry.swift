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

    // MARK: - Ladevorgang
    static func loadAll() {
        // 1. Raid Bosse laden
        let raids = RaidLoader.load()
        currentRaidBosses = Dictionary(
            uniqueKeysWithValues: raids.map { ($0.id, $0) }
        )

        // 2. Arcade Wellen laden
        currentArcadeWaves = ArcadeLoader.load()

        // 3. Spieler aus players.json laden
        playableCharacters = FighterLoader.load(file: "players")

        print(
            "✅ Registry synchronisiert: \(playableCharacters.count) Helden, \(currentRaidBosses.count) Raids, \(currentArcadeWaves.count) Arcade Waves"
        )
    }

    // MARK: - Abfragen (Das hat gefehlt!)

    /// Sucht einen Raid-Boss anhand der ID aus raid.json
    static func raidBoss(id: String) -> RaidBoss? {
        if currentRaidBosses.isEmpty { loadAll() }
        return currentRaidBosses[id]
    }

    /// Sucht einen spielbaren Charakter aus players.json
    static func getPlayer(id: String) -> Fighter? {
        if playableCharacters.isEmpty { loadAll() }
        return playableCharacters.first(where: { $0.id == id })
    }

    /// Findet einen Arcade-Gegner in den geladenen Wellen
    static func arcadeEnemy(id: Int) -> Fighter? {
        if currentArcadeWaves.isEmpty { loadAll() }
        for wave in currentArcadeWaves {
            for round in wave.rounds {
                if let enemy = round.first(where: { $0.id == id }) {
                    return enemy.toFighter()
                }
            }
        }
        return nil
    }
}
