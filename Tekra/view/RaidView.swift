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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [PlayerProgress]

    @State private var selectedBoss: RaidBoss?
    @State private var showingBossSelection = false

    // Grid-Konfiguration für 2 Spalten (Identisch mit ArcadeView)
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
    ]

    var body: some View {
        let theme = engine.progress?.theme

        ZStack {
            Color(hex: theme?.background.bottom ?? "#000000").ignoresSafeArea()

            if selectedBoss != nil {
                // MARK: - 3. KAMPF MODUS
                VStack(spacing: 0) {
                    BattleArenaView(engine: engine, showDefaultHUD: false)
                        .ignoresSafeArea()

                    VStack {
                        bossHealthHeader(theme: theme)
                        Spacer()
                        raidControlPanel(theme: theme)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .opacity
                    )
                )

                if engine.isLevelCleared {
                    raidVictoryOverlay(theme: theme)
                }

            } else if showingBossSelection {
                // MARK: - 2. BOSS AUSWAHL
                bossSelectionMenu(theme: theme)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        )
                    )
            } else {
                // MARK: - 1. CHARAKTER AUSWAHL (Rundes Grid)
                characterSelectionGrid(theme: theme)
                    .transition(.move(edge: .leading))
            }
        }
        .navigationBarHidden(true)
        .onAppear { setupDatabase() }
    }

    // MARK: - 1. Character Selection (Rundes Grid Layout)
    private func characterSelectionGrid(theme: Theme?) -> some View {
        let accentColor = Color.red  // Raid-spezifisches Rot

        return VStack(spacing: 0) {
            headerView(
                title: "RAID PREPARATION",
                subtitle: "SELECT YOUR PILOT",
                theme: theme,
                color: accentColor
            )
            .padding(.bottom, 20)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(FighterRegistry.playableCharacters) { character in
                        let isSelected =
                            engine.currentPlayer?.id == character.id

                        Button(action: {
                            withAnimation(
                                .spring(response: 0.3, dampingFraction: 0.7)
                            ) {
                                engine.selectPlayer(character)
                            }
                        }) {
                            VStack(spacing: 12) {
                                // RUNDES ICON (Wie in ArcadeView)
                                ZStack {
                                    Circle()
                                        .stroke(
                                            isSelected
                                                ? accentColor
                                                : Color.white.opacity(0.1),
                                            lineWidth: 3
                                        )
                                        .frame(width: 110, height: 110)

                                    if isSelected {
                                        Circle()
                                            .fill(accentColor.opacity(0.15))
                                            .frame(width: 100, height: 100)
                                            .blur(radius: 15)
                                    }

                                    Image(character.imageName)
                                        .resizable().scaledToFit().frame(
                                            width: 100,
                                            height: 100
                                        )
                                        .scaledToFill()
                                        .background(Color.black.opacity(0.4))
                                        .clipShape(Circle())
                                }

                                // NAME & MINI STATS (Kapsel-Design)
                                VStack(spacing: 4) {
                                    Text(character.name.uppercased())
                                        .font(
                                            .system(
                                                size: 14,
                                                weight: .black,
                                                design: .monospaced
                                            )
                                        )
                                        .foregroundColor(
                                            isSelected ? .white : .gray
                                        )

                                    HStack(spacing: 4) {
                                        Image(systemName: "bolt.fill")
                                        Text("\(Int(character.attackPower))")
                                    }
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        isSelected
                                            ? accentColor.opacity(0.2)
                                            : Color.white.opacity(0.05)
                                    )
                                    .foregroundColor(
                                        isSelected ? accentColor : .gray
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(20)
            }

            // Bestätigungs-Button unten fixiert
            if engine.currentPlayer != nil {
                Button(action: {
                    withAnimation(.spring()) { showingBossSelection = true }
                }) {
                    Text("CONFIRM PILOT")
                        .font(
                            .system(
                                size: 18,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(accentColor)
                        .cornerRadius(12)
                        .shadow(color: accentColor.opacity(0.4), radius: 10)
                }
                .padding(30)
            }
        }
    }

    // MARK: - 2. Boss Selection
    private func bossSelectionMenu(theme: Theme?) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView(
                    title: "TARGET ACQUISITION",
                    subtitle: "SELECT RAID BOSS",
                    theme: theme,
                    color: .red
                )

                ForEach(Array(FighterRegistry.currentRaidBosses.values)) {
                    boss in
                    Button(action: {
                        engine.startRaid(bossID: boss.id)
                        withAnimation { selectedBoss = boss }
                    }) {
                        HStack(spacing: 20) {
                            Image(boss.imageName)
                                .resizable().scaledToFill().frame(
                                    width: 60,
                                    height: 60
                                )
                                .background(Circle().fill(.black.opacity(0.3)))
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(boss.name.uppercased()).font(
                                    .system(
                                        size: 18,
                                        weight: .black,
                                        design: .monospaced
                                    )
                                ).foregroundColor(.white)
                                Text("CLASS: TITAN | HP: \(Int(boss.maxHP))")
                                    .font(.caption).foregroundColor(.red)
                            }
                            Spacer()
                            Image(systemName: "bolt.shield.fill")
                                .foregroundColor(.red)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(
                                Color.white.opacity(0.05)
                            )
                        )
                    }
                }

                Button("CHANGE PILOT") {
                    withAnimation { showingBossSelection = false }
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.gray).padding(.top, 10)
            }
            .padding()
        }
    }

    // MARK: - HUD & Overlays
    private func bossHealthHeader(theme: Theme?) -> some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width * 0.85
            let currentHP = engine.enemyHP
            let maxHP = max(engine.currentEnemy?.maxHP ?? 1, 1)
            let ratio = max(0, min(1, currentHP / maxHP))
            let barWidth = totalWidth * ratio

            VStack(spacing: 8) {
                HStack {
                    Text(engine.currentEnemy?.name.uppercased() ?? "BOSS")
                        .font(
                            .system(
                                size: 20,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)
                        .italic()
                    Spacer()
                    Text("\(Int(engine.enemyHP)) HP")
                        .font(
                            .system(
                                size: 14,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 40)
                .padding(.top, 50)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .frame(height: 12)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: barWidth, height: 12)
                }
                .frame(width: totalWidth)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: 100)
    }

    private func raidControlPanel(theme: Theme?) -> some View {
        VStack(spacing: 0) {
            Color.red.frame(height: 2).opacity(0.3)
            HStack(spacing: 15) {
                ForEach(engine.hand) { card in
                    ArcadeCardButton(card: card) { engine.playCard(card) }
                }
            }
        }
    }

    private func raidVictoryOverlay(theme: Theme?) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 30) {
                Text("RAID COMPLETED").font(
                    .system(size: 32, weight: .black, design: .monospaced)
                ).foregroundColor(.yellow).italic()
                RewardView(label: "BOSS LOOT", value: "+500 XP", color: .red)
                Button("RETURN TO HUB") { dismiss() }.font(
                    .system(size: 20, weight: .bold, design: .monospaced)
                ).foregroundColor(.black).padding(.horizontal, 50).padding(
                    .vertical,
                    15
                ).background(Color.green).cornerRadius(12)
            }
        }
    }

    private func headerView(
        title: String,
        subtitle: String,
        theme: Theme?,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(
                .system(size: 14, weight: .bold, design: .monospaced)
            ).foregroundColor(color)
            Text(subtitle).font(
                .system(size: 26, weight: .black, design: .monospaced)
            ).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(
            .horizontal,
            25
        ).padding(.top, 40)
    }

    private func setupDatabase() {
        if let firstProgress = allProgress.first {
            engine.setupDatabase(
                context: modelContext,
                playerProgress: firstProgress
            )
        }
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
