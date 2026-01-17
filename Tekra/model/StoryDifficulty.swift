//
//  StoryDifficulty.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import Foundation
import SwiftUI

enum StoryDifficulty: String, Codable, Hashable {
    case normal
    case elite
    case boss

    var hpMultiplier: CGFloat {
        switch self {
        case .normal: return 1.0
        case .elite: return 1.3
        case .boss: return 2.0
        }
    }

    var damageMultiplier: CGFloat {
        switch self {
        case .normal: return 1.0
        case .elite: return 1.2
        case .boss: return 1.5
        }
    }
}

// ✅ UI-Helpers (Title + Color)
extension StoryDifficulty {
    var title: String {
        switch self {
        case .normal: return "NORMAL"
        case .elite: return "ELITE"
        case .boss: return "BOSS"
        }
    }

    var color: Color {
        switch self {
        case .normal: return .cyan
        case .elite: return .orange
        case .boss: return .red
        }
    }
}
