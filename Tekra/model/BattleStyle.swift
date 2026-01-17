//
//  BattleStyle.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import Foundation
import SwiftUI

struct BattleStyle {
    let accentColor: Color
    let title: String
    let subtitle: String
    let showBossHUD: Bool
    let victoryTitle: String
}

extension BattleStyle {
    static let arcade = BattleStyle(
        accentColor: .cyan,
        title: "ARCADE MODE",
        subtitle: "SELECT MISSION",
        showBossHUD: false,
        victoryTitle: "MISSION SUCCESS"
    )

    static let raid = BattleStyle(
        accentColor: .red,
        title: "RAID MODE",
        subtitle: "TARGET ACQUIRED",
        showBossHUD: true,
        victoryTitle: "RAID COMPLETED"
    )

    static let event = BattleStyle(
        accentColor: .purple,
        title: "WORLD EVENT",
        subtitle: "MISSION BRIEFING",
        showBossHUD: false,
        victoryTitle: "EVENT COMPLETED"
    )
}
