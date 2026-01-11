//
//  ArcadeView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct ArcadeView: View {

    @EnvironmentObject var themeManager: ThemeManager
    var theme: Theme { themeManager.current }

    @State private var p1X: CGFloat = -90
    @State private var p2X: CGFloat = 90

    @State private var roster: [Fighter] = []
    @State private var enemies: [Fighter] = []

    @State private var playerIndex = 0
    @State private var enemyIndex = 0

    @State private var playerExp: CGFloat = 100
    @State private var enemyHP: CGFloat = 100

    @State private var levelCleared = false

    @State private var waves: [ArcadeWave] = ArcadeLoader.load()
    @State private var waveIndex = 0
    @State private var showArcadeSelect = true
    @State private var roundIndex = 0
    @State private var showRoundClear = false
    @State private var showWaveClear = false
    @State private var stickPower: CGFloat = 0
    @State private var fireTimer: Timer?

    let screenLimit: CGFloat = 140

    var player: Fighter? {
        roster.indices.contains(playerIndex) ? roster[playerIndex] : nil
    }
    var enemy: Fighter? {
        enemies.indices.contains(enemyIndex) ? enemies[enemyIndex] : nil
    }

    var body: some View {
        ZStack {
            theme.chromeGradient()
                .ignoresSafeArea()

            GameBoyView {
                VStack {

                    // HUD
                    HStack {
                        EXPBar(current: playerExp, max: 100)
                        Spacer()
                        HPBar(current: enemyHP, max: enemy?.maxHP ?? 100)
                    }
                    .padding()

                    Spacer()

                    // Fighters
                    if let player = player, let enemy = enemy {
                        HStack {
                            Image(player.image)
                                .resizable()
                                .scaledToFit()
                                .offset(x: p1X)

                            Image(enemy.image)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(x: -1, y: 1)
                                .offset(x: p2X)
                        }
                    } else {
                        Text("Loading fighters...")
                            .foregroundColor(.white)
                    }

                    Spacer()

                }
                .background(
                    Image("skybox")
                        .resizable()
                        .scaledToFill()
                )
            }

            VStack {
                Text("WAVE \(waveIndex + 1)")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.yellow)
                    .shadow(radius: 6)
                    .padding(.top, 14)

                Spacer()
            }

            if levelCleared {
                Text("LEVEL CLEARED")
                    .font(.largeTitle.bold())
                    .foregroundColor(.yellow)
            }

            if showRoundClear {
                Text("ROUND CLEARED")
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.yellow)
                    .shadow(radius: 12)
                    .transition(.scale)
            }

            if showWaveClear {
                Text("WAVE CLEARED")
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(.orange)
                    .shadow(radius: 16)
                    .transition(.scale)
            }

            // 🎰 ARCADE FOOTER (pinned to bottom)
            if !showArcadeSelect {
                VStack {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 20) {

                        // LEFT – Stick
                        ArcadeStick { power in
                            updateStickPower(power)
                        }

                        // RIGHT – Arcade Buttons (wrapfähig)
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 70), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ArcadeActionButton(title: "LP", color: .blue) {
                                switchPlayer()
                            }
                            ArcadeActionButton(title: "RP", color: .yellow) {
                                attack()
                            }
                            ArcadeActionButton(title: "LK", color: .red) {
                                attack()
                            }
                            ArcadeActionButton(title: "RK", color: .green) {
                                attack()
                            }
                            ArcadeActionButton(title: "LP", color: .orange) {
                                attack()
                            }
                            ArcadeActionButton(title: "RP", color: .indigo) {
                                attack()
                            }
                        }
                    }
                    .padding()
                }
            }

            if showArcadeSelect {
                Color.black.opacity(0.85).ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("ARCADE MODE")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    ForEach(Array(waves.enumerated()), id: \.offset) { pair in
                        let index = pair.offset
                        let wave = pair.element

                        Button {
                            startArcade(index)
                        } label: {
                            Text(wave.title)
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color(
                                                        hex: theme.metal
                                                            .highlight
                                                    ),
                                                    Color(
                                                        hex: theme.metal
                                                            .edgeGlow
                                                    ),
                                                    Color(
                                                        hex: theme.metal.shadow
                                                    ),
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: theme.metal.shadow),
                                    Color(hex: theme.metal.edgeGlow),
                                    Color(hex: theme.metal.highlight),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: Color(hex: theme.metal.edgeGlow),
                            radius: 30
                        )
                )
                .padding(.horizontal, 24)
            }
        }
        .onAppear(perform: loadGame)
    }

    func updateStickPower(_ power: CGFloat) {
        stickPower = power

        if power == 0 {
            fireTimer?.invalidate()
            fireTimer = nil
            return
        }

        if fireTimer == nil {
            fireTimer = Timer.scheduledTimer(
                withTimeInterval: max(0.05, 0.35 - power * 0.3),
                repeats: true
            ) { _ in
                attack()
            }
        }
    }

    // MARK: Game Logic
    func loadGame() {
        roster = PlayerRosterLoader.load()
        playerIndex = 0
        enemyIndex = 0
        playerExp = 0
        levelCleared = false

        roundIndex = 0
        enemies = waves[waveIndex].rounds[roundIndex]
        enemyHP = enemies.first?.maxHP ?? 0
    }

    func startArcade(_ index: Int) {
        showArcadeSelect = false
        waveIndex = index
        enemyIndex = 0
        enemyHP = enemies.first?.maxHP ?? 0
        levelCleared = false
    }

    func switchPlayer() {
        guard !roster.isEmpty else { return }
        playerIndex = (playerIndex + 1) % roster.count
    }

    func attack() {
        guard let player = player else { return }
        guard enemyHP > 0 else { return }  // <- wichtig

        enemyHP = max(enemyHP - CGFloat(player.attack), 0)

        if enemyHP == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                nextEnemy()
            }
        }
    }

    func nextEnemy() {
        playerExp = min(playerExp + 25, 100)

        let nextEnemyIndex = enemyIndex + 1
        if enemies.indices.contains(nextEnemyIndex) {
            enemyIndex = nextEnemyIndex
            enemyHP = enemies[enemyIndex].maxHP
            return
        }

        // ROUND CLEARED
        if waves[waveIndex].rounds.indices.contains(roundIndex + 1) {
            withAnimation { showRoundClear = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showRoundClear = false
                roundIndex += 1
                enemies = waves[waveIndex].rounds[roundIndex]
                enemyIndex = 0
                enemyHP = enemies.first?.maxHP ?? 0
            }
            return
        }

        // WAVE CLEARED
        withAnimation { showWaveClear = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            showWaveClear = false
            waveIndex = (waveIndex + 1) % waves.count
            roundIndex = 0
            enemies = waves[waveIndex].rounds[roundIndex]
            enemyIndex = 0
            enemyHP = enemies.first?.maxHP ?? 0
        }
    }
}

#Preview {
    ArcadeView()
        .environmentObject(
            ThemeManager(theme: ThemeLoader.load())
        )
}
