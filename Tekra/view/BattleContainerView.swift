//
//  BattleContainerView.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct BattleContainerView<ControlPanel: View>: View {

    enum Style {
        case arcade
        case raid
        case event
    }

    let style: Style
    let event: GameEvent?
    let onExit: () -> Void
    let controlPanel: ControlPanel

    @Environment(GameEngine.self) private var engine

    init(
        style: Style,
        event: GameEvent? = nil,
        onExit: @escaping () -> Void,
        @ViewBuilder controlPanel: () -> ControlPanel
    ) {
        self.style = style
        self.event = event
        self.onExit = onExit
        self.controlPanel = controlPanel()
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // ✅ DAS ist dein "battleView"
            VStack(spacing: 0) {
                BattleArenaView(
                    engine: engine,
                    showDefaultHUD: style != .raid
                )

                controlPanel
            }

            if engine.isLevelCleared {
                VictoryOverlayView(
                    style: mapStyle,
                    event: event,
                    onExit: onExit
                )
            }
        }
    }

    private var mapStyle: VictoryOverlayView.Style {
        switch style {
        case .arcade: return .arcade
        case .raid: return .raid
        case .event: return .event
        }
    }
}
