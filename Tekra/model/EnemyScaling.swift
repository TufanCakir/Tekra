//
//  EnemyScaling.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//
import Foundation

struct EnemyScaling {

    static func scaledHP(
        baseHP: CGFloat,
        playerLevel: Int,
        mode: GameMode
    ) -> CGFloat {

        let levelMultiplier = pow(1.08, CGFloat(playerLevel - 1))  // ⬅️ sanft!

        let modeMultiplier: CGFloat =
            switch mode {
            case .arcade: 1.0
            case .event: 1.3
            case .raid: 1.8
            }

        return baseHP * levelMultiplier * modeMultiplier
    }

    static func scaledAttack(
        baseAttack: CGFloat,
        playerLevel: Int,
        mode: GameMode
    ) -> CGFloat {

        let levelMultiplier = pow(1.06, CGFloat(playerLevel - 1))

        let modeMultiplier: CGFloat =
            switch mode {
            case .arcade: 1.0
            case .event: 1.2
            case .raid: 1.4
            }

        return baseAttack * levelMultiplier * modeMultiplier
    }
}
