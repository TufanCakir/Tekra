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

        let enemy = enemyData.toFighter()

        applyMatchSettings(
            enemy: enemy,
            background: engine.currentBackground
        )

        engine.currentRoundIndex = index
        print("🕹 Arcade Runde \(index + 1): \(enemy.name)")
    }

    // MARK: - Raid

    func startRaid(bossID: String) {
        guard let engine else { return }

        engine.currentMode = .raid

        if let boss = FighterRegistry.raidBoss(id: bossID) {
            applyMatchSettings(
                enemy: boss.toFighter(),
                background: boss.raidBackground
            )
        }
    }

    // MARK: - Event

    func startEvent(_ event: GameEvent) {
        guard let engine else { return }

        engine.currentMode = .event

        if let enemyID = event.enemies.first {
            let enemy = Fighter(
                id: event.id,
                name: event.title,
                imageName: enemyID,
                maxHP: 100,
                attackPower: 20
            )

            applyMatchSettings(
                enemy: enemy,
                background: event.background
            )
        }
    }

    // MARK: - Shared

    private func applyMatchSettings(
        enemy: Fighter,
        background: String
    ) {
        guard let engine else { return }

        engine.currentEnemy = enemy
        engine.enemyHP = enemy.maxHP
        engine.playerHP = engine.currentPlayer?.maxHP ?? 100
        engine.currentBackground = background

        engine.isLevelCleared = false
        engine.isPerformingAction = false
        engine.currentPose = "idle"
        engine.p1X = 0
        engine.hand = Array(engine.allCards.shuffled().prefix(3))
    }
}
