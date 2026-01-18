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
    @State private var showGameOver = false

    var body: some View {
        ZStack {
            if started {
                ZStack {

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

                    // 💀 GAME OVER OVERLAY
                    if showGameOver {
                        GameOverOverlayView {
                            engine.hardResetBattle()
                            started = false
                            showGameOver = false
                        }
                    }
                }
                .transition(.opacity)
            } else {
                arcadeSetupView
            }
        }
        .animation(.easeOut(duration: 0.25), value: started)
        .onChange(of: engine.playerHP) { _, newHP in
            if newHP <= 0 && !showGameOver && started {
                withAnimation(.easeOut(duration: 0.25)) {
                    showGameOver = true
                }
            }
        }
    }

    private var arcadeRecommendedLevel: Int {
        // 🔧 Minimal & sicher
        FighterRegistry.currentArcadeWaves.first?.recommendedLevel ?? 1
    }

    private var arcadeDifficulty: DifficultyRating {
        let playerLevel = engine.progress?.playerLevel ?? 1
        return DifficultyEvaluator.rating(
            playerLevel: playerLevel,
            recommendedLevel: arcadeRecommendedLevel
        )
    }

    private var difficultyBadge: some View {
        let rating = arcadeDifficulty

        return HStack(spacing: 10) {
            Text("RECOMMENDED LV \(arcadeRecommendedLevel)")
                .font(.caption.bold())

            Text(rating.label)
                .font(.caption.bold())
                .foregroundColor(rating.color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(rating.color.opacity(0.15))
        .clipShape(Capsule())
    }

    // MARK: - ARCADE SETUP
    private var arcadeSetupView: some View {
        Group {
            let blocked =
                engine.currentPlayer == nil || arcadeDifficulty == .impossible

            VStack(spacing: 28) {

                // Header
                VStack(spacing: 6) {
                    Text("ARCADE MODE")
                        .font(.caption.bold())
                        .foregroundColor(.cyan)

                    Text("SELECT YOUR PILOT")
                        .font(
                            .system(
                                size: 26,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)
                }

                // 🧠 DIFFICULTY BADGE
                difficultyBadge

                // Charakterauswahl
                CharacterPickerView()
                    .frame(maxHeight: 300)

                Spacer()

                // Start Button
                Button {
                    guard let wave = FighterRegistry.currentArcadeWaves.first
                    else {
                        print("❌ No Arcade Waves available")
                        return
                    }

                    engine.startArcade(wave: wave)
                    started = true

                } label: {
                    Text(
                        arcadeDifficulty == .impossible
                            ? "LEVEL TOO LOW"
                            : "START ARCADE"
                    )
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
                .disabled(blocked)
                .opacity(blocked ? 0.4 : 1)

            }
            .padding()
            .background(Color.black.ignoresSafeArea())
        }
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
