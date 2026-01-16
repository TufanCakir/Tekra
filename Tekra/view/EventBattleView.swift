//
//  EventBattleView.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftData
import SwiftUI

struct EventBattleView: View {
    @Environment(GameEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [PlayerProgress]

    // States für den Ablauf (Identisch mit Arcade/Raid)
    var event: GameEvent  // Das Event wird beim Öffnen übergeben
    @State private var showingEventDetails = false
    @State private var startBattle = false

    var body: some View {
        let theme = engine.progress?.theme
        let accentColor = Color.purple  // Event-Farbe

        ZStack {
            Color(hex: theme?.background.bottom ?? "#000000").ignoresSafeArea()

            if startBattle {
                // MARK: - 3. KAMPF MODUS
                VStack(spacing: 0) {
                    BattleArenaView(engine: engine)
                        .ignoresSafeArea()
                    eventControlPanel(theme: theme)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .opacity
                    )
                )

                if engine.isLevelCleared {
                    eventVictoryOverlay(theme: theme)
                }

            } else if showingEventDetails {
                // MARK: - 2. EVENT BRIEFING
                eventBriefingMenu(theme: theme, accentColor: accentColor)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        )
                    )
            } else {
                // MARK: - 1. CHARAKTER AUSWAHL (Grid)
                characterSelectionGrid(theme: theme, accentColor: accentColor)
                    .transition(.move(edge: .leading))
            }
        }
        .navigationBarHidden(true)
        .onAppear { setupDatabase() }
    }

    // MARK: - 1. Character Selection (Einheitliches Grid)
    private func characterSelectionGrid(theme: Theme?, accentColor: Color)
        -> some View
    {
        VStack(spacing: 0) {
            headerView(
                title: "EVENT PREPARATION",
                subtitle: "SELECT YOUR PILOT",
                color: accentColor
            )

            ScrollView {
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(FighterRegistry.playableCharacters) { character in
                        let isSelected =
                            engine.currentPlayer?.id == character.id
                        Button(action: {
                            withAnimation(.spring()) {
                                engine.selectPlayer(character)
                            }
                        }) {
                            VStack(spacing: 10) {
                                Image(character.imageName)
                                    .resizable().scaledToFit().frame(
                                        width: 100,
                                        height: 100
                                    )
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(
                                            isSelected
                                                ? accentColor
                                                : Color.white.opacity(0.1),
                                            lineWidth: 3
                                        )
                                    )
                                    .shadow(
                                        color: isSelected
                                            ? accentColor.opacity(0.5) : .clear,
                                        radius: 10
                                    )

                                Text(character.name.uppercased()).font(
                                    .system(
                                        size: 14,
                                        weight: .black,
                                        design: .monospaced
                                    )
                                ).foregroundColor(isSelected ? .white : .gray)
                            }
                        }
                    }
                }
                .padding(20)
            }

            if engine.currentPlayer != nil {
                Button(action: {
                    withAnimation(.spring()) { showingEventDetails = true }
                }) {
                    Text("CONFIRM PILOT").font(
                        .system(size: 18, weight: .bold, design: .monospaced)
                    )
                    .foregroundColor(.white).frame(maxWidth: .infinity)
                    .padding().background(accentColor).cornerRadius(12)
                }
                .padding(30)
            }
        }
    }

    // MARK: - 2. Event Briefing (Spezifisch für Events)
    private func eventBriefingMenu(theme: Theme?, accentColor: Color)
        -> some View
    {
        VStack(spacing: 30) {
            headerView(
                title: "MISSION BRIEFING",
                subtitle: event.title.uppercased(),
                color: accentColor
            )

            VStack(alignment: .leading, spacing: 15) {
                Label("REWARD: \(event.rewardXP) XP", systemImage: "star.fill")
                Label(
                    "CURRENCY: \(event.rewardCoins) COINS",
                    systemImage: "bitcoinsign.circle.fill"
                )
                Text(event.description)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15).fill(
                    Color.white.opacity(0.05)
                )
            )
            .padding(.horizontal)

            Spacer()

            Button(action: {
                engine.loadEvent(event)
                withAnimation { startBattle = true }
            }) {
                Text("START EVENT").font(
                    .system(size: 20, weight: .black, design: .monospaced)
                )
                .foregroundColor(.black).frame(maxWidth: .infinity).padding()
                .background(Color.yellow).cornerRadius(12)
            }
            .padding(30)
        }
    }

    private func eventControlPanel(theme: Theme?) -> some View {
        VStack(spacing: 0) {
            Color.purple.frame(height: 2).opacity(0.3)
            HStack(spacing: 15) {
                ForEach(engine.hand) { card in
                    ArcadeCardButton(card: card) { engine.playCard(card) }
                }
            }
        }
    }

    private func eventVictoryOverlay(theme: Theme?) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 30) {
                Text("EVENT COMPLETED").font(
                    .system(size: 32, weight: .black, design: .monospaced)
                ).foregroundColor(.yellow).italic()
                HStack(spacing: 40) {
                    RewardView(
                        label: "XP",
                        value: "+\(event.rewardXP)",
                        color: .purple
                    )
                    RewardView(
                        label: "COINS",
                        value: "+\(event.rewardCoins)",
                        color: .orange
                    )
                }
                .padding(25).background(Color.white.opacity(0.05)).cornerRadius(
                    20
                )

                Button("RETURN TO HUB") { dismiss() }
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.black).padding(.horizontal, 50).padding(
                        .vertical,
                        15
                    ).background(Color.green).cornerRadius(12)
            }
        }
    }

    private func headerView(title: String, subtitle: String, color: Color)
        -> some View
    {
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
    // 1. Registry manuell laden, damit Charaktere im Grid erscheinen
    FighterRegistry.loadAll()

    // 2. Ein Test-Event erstellen, damit die View Daten zum Anzeigen hat
    let mockEvent = GameEvent(
        id: "preview_event",
        title: "Test Expedition",
        description: "Dies ist eine Test-Beschreibung für das Preview.",
        background: "skybox",
        enemies: ["ice_warrior"],
        rewards: [
            EventReward(type: .xp, amount: 100, idRef: nil),
            EventReward(type: .coins, amount: 50, idRef: nil),
        ],
        requiredLevel: 1,
        active: true
    )

    let previewEngine = GameEngine()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PlayerProgress.self,
        configurations: config
    )

    return EventBattleView(event: mockEvent)  // <-- Hier das mockEvent übergeben
        .environment(previewEngine)
        .modelContainer(container)
}
