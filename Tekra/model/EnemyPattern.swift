//
//  EnemyPattern.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

enum EnemyPatternStep {
    case attack(multiplier: CGFloat)
    case heavyAttack
    case wait
    case enrage
}
