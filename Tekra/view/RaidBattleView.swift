//
//  RaidBattleView.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftData
import SwiftUI

struct RaidBattleView: View {
    @Environment(GameEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    let boss: RaidBoss
    @State private var started = false
    @State private var showGameOver = false

    var body: some View {
        ZStack {
            if started {
                battleView
            } else {
                raidIntroView
            }
        }
        .onAppear {
            engine.startRaid(bossID: boss.id)
        }
    }

    private var raidIntroView: some View {
        let playerLevel = engine.progress?.playerLevel ?? 1
        let rating = DifficultyEvaluator.rating(
            playerLevel: playerLevel,
            recommendedLevel: boss.recommendedLevel
        )

        return ZStack {
            // Hintergrund
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0.85),
                    Color.red.opacity(0.15),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {

                Spacer()

                // RAID LABEL
                Text("RAID BOSS")
                    .font(.caption.bold())
                    .foregroundColor(.red)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.15))
                    .clipShape(Capsule())

                // 🔥 DIFFICULTY BADGE
                HStack(spacing: 10) {
                    Text("RECOMMENDED LV \(boss.recommendedLevel)")
                        .font(.caption.bold())

                    Text(rating.label)
                        .font(.caption.bold())
                        .foregroundColor(rating.color)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(rating.color.opacity(0.18))
                .clipShape(Capsule())

                // BOSS NAME
                Text(boss.name.uppercased())
                    .font(
                        .system(size: 34, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .red.opacity(0.6), radius: 12)

                Text("THIS ENEMY CANNOT BE DEFEATED ALONE")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .tracking(1.2)

                Spacer()

                // ENTER BUTTON
                let blocked = rating == .impossible

                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        started = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")

                        Text(
                            rating == .impossible
                                ? "LEVEL TOO LOW"
                                : "ENTER RAID"
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.red, .red.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.6), radius: 18, y: 8)
                }
                .disabled(blocked)
                .opacity(blocked ? 0.4 : 1)
                .padding(.horizontal, 24)

                Spacer(minLength: 40)
            }
        }
    }

    private var battleView: some View {
        ZStack {

            // 🔥 MAIN BATTLE
            BattleContainerView(
                style: .raid,
                onExit: {
                    engine.hardResetBattle()
                    dismiss()
                },
                controlPanel: {
                    BattleControlPanel(
                        color: .red,
                        cards: engine.hand,
                        onPlay: engine.playCard
                    )
                }
            )

            // 🧠 UI OVERLAY
            VStack {
                // BOSS HP
                if let enemy = engine.currentEnemy {
                    BossHealthBar(
                        bossName: enemy.name,
                        currentHP: engine.enemyHP,
                        maxHP: enemy.maxHP
                    )
                    .padding()
                }

                Spacer()

                // PLAYER HP
                if let player = engine.currentPlayer {
                    HStack {
                        PlayerHealthBar(
                            playerName: player.name,
                            currentHP: engine.playerHP,
                            maxHP: player.maxHP
                        )
                        Spacer()
                    }
                    .padding(.bottom, 200)
                    .padding()
                }
            }

            // 💀 GAME OVER OVERLAY
            if showGameOver {
                GameOverOverlayView {
                    engine.hardResetBattle()
                    dismiss()
                }
            }
        }
        // 👇 PLAYER-DEFEAT WATCHER
        .onChange(of: engine.playerHP) { _, newHP in
            if newHP <= 0 && !showGameOver {
                withAnimation(.easeOut(duration: 0.25)) {
                    showGameOver = true
                }
            }
        }
    }
}

#Preview("Raid Battle – Void Reaper") {
    let engine = GameEngine()

    // 🔧 Fake Boss
    let boss = RaidBoss(
        id: "void_reaper",
        name: "The Void Reaper",
        imageName: "void_reaper",
        maxHP: 2500,
        attackPower: 60,
        raidBackground: "arena_1",
        availablePoses: ["idle", "punch", "kick", "special"]
    )

    // 🔧 Fake Player
    let player = Fighter(
        id: "sly",
        name: "Sly",
        imageName: "sly",
        maxHP: 120,
        attackPower: 20,
        availablePoses: ["idle", "punch", "kick"],
        cardOwners: ["generic"]
    )

    // 🔧 Engine vorbereiten
    engine.currentPlayer = player
    engine.playerHP = player.maxHP
    engine.currentEnemy = boss.makeFighter()
    engine.enemyHP = boss.maxHP

    return RaidBattleView(boss: boss)
        .environment(engine)
        .preferredColorScheme(.dark)
}
