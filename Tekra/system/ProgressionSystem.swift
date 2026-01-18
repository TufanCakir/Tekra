//
//  ProgressionSystem.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

final class ProgressionSystem {

    func rewards(for mode: GameMode) -> (xp: Int, coins: Int) {
        switch mode {
        case .arcade:
            return (xp: 75, coins: 20)
        case .raid:
            return (xp: 50, coins: 10)
        case .event:
            return (xp: 100, coins: 30)
        }
    }

    func applyVictoryRewards(
        mode: GameMode,
        progress: PlayerProgress?
    ) {
        guard let progress else { return }

        let reward = rewards(for: mode)
        progress.addXP(reward.xp)
        progress.addCoins(reward.coins)

        print("🏆 Rewards: +\(reward.xp) XP, +\(reward.coins) Coins")
    }
}
