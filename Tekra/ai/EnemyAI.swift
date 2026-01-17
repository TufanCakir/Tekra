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

    func configurePattern(for enemy: Fighter) {
        enemyMaxHP = enemy.maxHP
        currentPhase = .phase1
        loadPattern(for: .phase1)
    }

    func updatePhaseIfNeeded(currentHP: CGFloat) {
        let hpRatio = currentHP / enemyMaxHP

        switch hpRatio {
        case ..<0.2 where currentPhase != .enraged:
            currentPhase = .enraged
            loadPattern(for: .enraged)

        case ..<0.5 where currentPhase == .phase1:
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
                .heavyAttack,
                .attack(multiplier: 1.0),
            ])

        case .enraged:
            patternState = EnemyPatternState(pattern: [
                .attack(multiplier: 1.5),
                .heavyAttack,
                .enrage,
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

        switch step {
        case .attack(let multiplier):
            return .basicAttack(multiplier)
        case .heavyAttack:
            return .heavyAttack
        case .wait:
            return .wait
        case .enrage:
            return .enrage
        }
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
