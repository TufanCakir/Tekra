//
//  PlayerScaling.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import Foundation

struct PlayerScaling {

    static func scaledHP(
        baseHP: CGFloat,
        playerLevel: Int
    ) -> CGFloat {
        // Spieler wird deutlich tankiger
        let levelMultiplier = pow(1.10, CGFloat(playerLevel - 1))
        return baseHP * levelMultiplier
    }

    static func scaledAttack(
        baseAttack: CGFloat,
        playerLevel: Int
    ) -> CGFloat {
        // Schaden steigt moderat
        let levelMultiplier = pow(1.07, CGFloat(playerLevel - 1))
        return baseAttack * levelMultiplier
    }
}
