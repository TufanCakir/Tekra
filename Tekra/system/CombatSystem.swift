//
//  CombatSystem.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

final class CombatSystem {

    func applyDamage(
        damage: CGFloat,
        to hp: inout CGFloat
    ) -> Bool {
        hp = max(hp - damage, 0)
        return hp <= 0
    }
}
