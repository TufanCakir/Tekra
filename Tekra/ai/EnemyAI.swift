//
//  EnemyAI.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

final class EnemyAI {

    private var patternState: EnemyPatternState?
    private var currentPhase: EnemyPhase = .phase1
    private var enemyMaxHP: CGFloat = 100
    private var comboCounter: Int = 0
    private let maxCombo = 3

    func configurePattern(for enemy: Fighter) {
        enemyMaxHP = enemy.maxHP
        currentPhase = .phase1
        comboCounter = 0
        loadPattern(for: .phase1)
    }

    func updatePhaseIfNeeded(currentHP: CGFloat) {
        let hpRatio = currentHP / enemyMaxHP

        switch hpRatio {
        case ..<0.2 where currentPhase != .enraged:
            currentPhase = .enraged
            loadPattern(for: .enraged)

        case ..<0.7 where currentPhase == .phase1:
            currentPhase = .phase2
            loadPattern(for: .phase2)

        default:
            break
        }
    }

    private func loadPattern(for phase: EnemyPhase) {
        switch phase {

        case .phase1:
            patternState = EnemyPatternState(pattern: [
                .attack(multiplier: 1.0),
                .attack(multiplier: 1.0),
                .wait,
            ])

        case .phase2:
            patternState = EnemyPatternState(pattern: [
                .attack(multiplier: 1.2),
                .attack(multiplier: 1.2),
                .heavyAttack,
                .wait,
            ])

        case .enraged:
            patternState = EnemyPatternState(pattern: [
                .attack(multiplier: 1.4),
                .heavyAttack,
                .attack(multiplier: 1.6),
                .heavyAttack,
            ])
        }
    }

    func chooseAction(
        enemy: Fighter,
        playerHP: CGFloat
    ) -> EnemyAction {

        guard let step = patternState?.next() else {
            return .basicAttack(1.0)
        }

        // 🔥 COMBO LOGIC
        if comboCounter >= maxCombo {
            comboCounter = 0
            return .wait
        }

        switch step {

        case .attack(let multiplier):
            comboCounter += 1

            // 💥 Punish low player HP
            if playerHP < 40 && multiplier >= 1.2 {
                comboCounter += 1
                return .heavyAttack
            }

            return .basicAttack(multiplier)

        case .heavyAttack:
            comboCounter += 2
            return .heavyAttack

        case .enrage:
            comboCounter = 0
            return .enrage

        case .wait:
            comboCounter = 0
            return .wait
        }
    }

    enum EnemyAction {
        case basicAttack(CGFloat)
        case heavyAttack
        case wait
        case enrage
    }

    enum EnemyPhase {
        case phase1
        case phase2
        case enraged
    }
}
