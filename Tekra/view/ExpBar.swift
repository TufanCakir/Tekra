//
//  ExpBar.swift
//  Tekra
//
//  Created by Tufan Cakir on 10.01.26.
//

import SwiftUI

struct EXPBar: View {
    @EnvironmentObject var themeManager: ThemeManager
    var theme: Theme { themeManager.current }
    var current: CGFloat
    var max: CGFloat

    var body: some View {
        UniversalBar(
            progress: current / max,
            core: theme.hud.exp.core,
            glow: theme.hud.exp.glow
        )
    }
}
