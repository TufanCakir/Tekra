//
//  RaidView.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftData
import SwiftUI

struct RaidView: View {
    @Environment(GameEngine.self) private var engine
    @State private var started = false
    @State private var selectedBoss: RaidBoss?

    var body: some View {
        ZStack {
            if started {
                ZStack(alignment: .top) {

                    // 🕹 Kampf
                    BattleContainerView(
                        style: .raid,
                        onExit: {
                            started = false
                            engine.isLevelCleared = false
                        },
                        controlPanel: {
                            BattleControlPanel(
                                color: .red,
                                cards: engine.hand,
                                onPlay: engine.playCard
                            )
                        }
                    )

                    // 🧠 Boss HUD
                    if let enemy = engine.currentEnemy {
                        BossHealthBar(
                            currentHP: engine.enemyHP,
                            maxHP: enemy.maxHP
                        )
                        .padding(.top, 40)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            } else {
                raidSetupView
            }
        }
        .animation(.easeOut(duration: 0.25), value: started)
    }

    // MARK: - RAID SETUP
    private var raidSetupView: some View {
        VStack(spacing: 28) {

            // Header
            VStack(spacing: 6) {
                Text("RAID PREPARATION")
                    .font(.caption.bold())
                    .foregroundColor(.red)

                Text("SELECT PILOT & BOSS")
                    .font(
                        .system(size: 26, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.white)
            }

            // Charaktere
            CharacterPickerView()
                .frame(maxHeight: 260)

            // Boss-Auswahl
            VStack(alignment: .leading, spacing: 12) {
                Text("TARGET")
                    .font(.caption.bold())
                    .foregroundColor(.red)

                ForEach(Array(FighterRegistry.currentRaidBosses.values)) {
                    boss in
                    Button {
                        selectedBoss = boss
                    } label: {
                        HStack {
                            Text(boss.name.uppercased())
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .bold,
                                        design: .monospaced
                                    )
                                )
                            Spacer()
                            if selectedBoss?.id == boss.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    selectedBoss?.id == boss.id
                                        ? Color.red.opacity(0.15)
                                        : Color.white.opacity(0.05)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Start Button
            Button {
                guard
                    let boss = selectedBoss,
                    engine.currentPlayer != nil
                else { return }

                engine.startRaid(bossID: boss.id)
                started = true

            } label: {
                Text("START RAID")
                    .font(
                        .system(size: 18, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(14)
            }
            .disabled(selectedBoss == nil || engine.currentPlayer == nil)
            .opacity(
                selectedBoss == nil || engine.currentPlayer == nil ? 0.4 : 1
            )

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    FighterRegistry.loadAll()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PlayerProgress.self,
        configurations: config
    )
    let engine = GameEngine()
    return RaidView().environment(engine).modelContainer(container)
}
