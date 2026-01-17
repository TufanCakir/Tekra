//
//  ArcadeView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftData
import SwiftUI

struct ArcadeView: View {
    @Environment(GameEngine.self) private var engine
    @State private var started = false

    var body: some View {
        ZStack {
            if started {
                BattleContainerView(
                    style: .arcade,
                    onExit: {
                        engine.isLevelCleared = false
                        started = false
                    },
                    controlPanel: {
                        BattleControlPanel(
                            color: .blue,
                            cards: engine.hand,
                            onPlay: engine.playCard
                        )
                    }
                )
                .transition(.opacity)
            } else {
                arcadeSetupView
            }
        }
        .animation(.easeOut(duration: 0.25), value: started)
    }

    // MARK: - ARCADE SETUP
    private var arcadeSetupView: some View {
        VStack(spacing: 28) {

            // Header
            VStack(spacing: 6) {
                Text("ARCADE MODE")
                    .font(.caption.bold())
                    .foregroundColor(.cyan)

                Text("SELECT YOUR PILOT")
                    .font(
                        .system(size: 26, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.white)
            }

            // Charakterauswahl
            CharacterPickerView()
                .frame(maxHeight: 300)

            Spacer()

            // Start Button
            Button {
                guard engine.currentPlayer != nil else { return }
                guard let wave = FighterRegistry.currentArcadeWaves.first else {
                    print("❌ No Arcade Waves available")
                    return
                }

                engine.startArcade(wave: wave)
                started = true

            } label: {
                Text("START ARCADE")
                    .font(
                        .system(size: 18, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan)
                    .cornerRadius(14)
                    .shadow(color: .cyan.opacity(0.4), radius: 10)
            }
            .disabled(engine.currentPlayer == nil)
            .opacity(engine.currentPlayer == nil ? 0.4 : 1)

        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    // VOR dem Preview die Daten laden!
    FighterRegistry.loadAll()

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PlayerProgress.self,
        configurations: config
    )
    let engine = GameEngine()

    return ArcadeView()
        .environment(engine)
        .modelContainer(container)
}
