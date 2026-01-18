//
//  DifficultyRating.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import Foundation
import SwiftUI

enum DifficultyRating {
    case easy
    case fair
    case hard
    case impossible

    var label: String {
        switch self {
        case .easy: return "OVERPOWERED"
        case .fair: return "EVEN MATCH"
        case .hard: return "BRUTAL"
        case .impossible: return "SUICIDE"
        }
    }

    var color: Color {
        switch self {
        case .easy: return .green
        case .fair: return .yellow
        case .hard: return .orange
        case .impossible: return .red
        }
    }
}

struct DifficultyEvaluator {

    static func rating(
        playerLevel: Int,
        recommendedLevel: Int
    ) -> DifficultyRating {

        let diff = playerLevel - recommendedLevel

        switch diff {
        case 6...:
            return .easy
        case 2...5:
            return .fair
        case -2...1:
            return .hard
        default:
            return .impossible
        }
    }
}
#Preview {

}
