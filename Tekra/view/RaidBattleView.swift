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
        ZStack {
            // Hintergrund
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0.85),
                    Color.red.opacity(0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {

                Spacer()

                // MARK: - Boss Label
                Text("RAID BOSS")
                    .font(.caption.bold())
                    .foregroundColor(.red)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.15))
                    .clipShape(Capsule())

                // MARK: - Boss Name
                Text(boss.name.uppercased())
                    .font(.system(size: 34, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .red.opacity(0.6), radius: 12)

                // Optional Flavor Text
                Text("THIS ENEMY CANNOT BE DEFEATED ALONE")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .tracking(1.2)

                Spacer()

                // MARK: - Enter Button
                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        started = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                        Text("ENTER RAID")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
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
                .padding(.horizontal, 24)

                Spacer(minLength: 40)
            }
        }
    }


    private var battleView: some View {
        ZStack(alignment: .top) {
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

            if let enemy = engine.currentEnemy {
                BossHealthBar(
                    currentHP: engine.enemyHP,
                    maxHP: enemy.maxHP
                )
                .padding(.top, 40)
            }
        }
    }
}
