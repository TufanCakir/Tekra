//
//  ModeController.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

final class ModeController {

    private weak var engine: GameEngine?

    init(engine: GameEngine) {
        self.engine = engine
    }

    // MARK: - Arcade

    func startArcade(wave: ArcadeWave) {
        guard let engine else { return }

        engine.currentMode = .arcade
        engine.currentWave = wave
        engine.currentRoundIndex = 0
        engine.currentBackground = wave.background

        loadArcadeRound(index: 0)
    }

    func nextArcadeRound() {
        guard let engine else { return }
        loadArcadeRound(index: engine.currentRoundIndex + 1)
    }

    private func loadArcadeRound(index: Int) {
        guard
            let engine,
            let wave = engine.currentWave,
            wave.rounds.indices.contains(index),
            let enemyData = wave.rounds[index].first
        else {
            engine?.isLevelCleared = true
            return
        }

        let enemy = enemyData.fighter
        applyMatchSettings(enemy: enemy, background: engine.currentBackground)

        engine.currentRoundIndex = index
        print("🕹 Arcade Runde \(index + 1): \(enemy.name)")
    }

    // MARK: - Raid
    func startRaid(bossID: String) {
        guard let engine else { return }

        engine.currentMode = .raid

        if let boss = FighterRegistry.raidBoss(id: bossID) {
            engine.currentRaidBoss = boss  // 🔥 WICHTIG

            applyMatchSettings(
                enemy: boss.makeFighter(),
                background: boss.raidBackground
            )
        }
    }

    // MARK: - Event
    func startEvent(_ event: GameEvent) {
        guard let engine else { return }

        engine.currentMode = .event

        // 🔑 FALLBACK PLAYER
        if engine.currentPlayer == nil {
            engine.currentPlayer = FighterRegistry.playableCharacters.first
        }

        // 🔥 STORY ENEMY DIREKT ERZEUGEN
        if let enemyID = event.enemies.first {

            let enemy: Fighter

            if let registryEnemy = FighterRegistry.enemy(id: enemyID) {
                enemy = registryEnemy
            } else {
                // 🔥 STORY FALLBACK
                enemy = Fighter(
                    id: enemyID,
                    name: "Event Enemy",
                    imageName: enemyID,
                    maxHP: 120,
                    attackPower: 18,
                    availablePoses: ["idle", "punch", "kick", "special"],
                    cardOwners: ["generic"]
                )
                print("🧪 Event fallback enemy created:", enemyID)
            }

            engine.applyMatchSettings(
                enemy: enemy,
                background: event.background
            )
        }

        engine.drawHand()
    }

    // MARK: - Shared
    private func applyMatchSettings(
        enemy: Fighter,
        background: String
    ) {
        guard let engine else {
            print("❌ ModeController: engine is nil")
            return
        }

        engine.applyMatchSettings(
            enemy: enemy,
            background: background
        )
    }
}
