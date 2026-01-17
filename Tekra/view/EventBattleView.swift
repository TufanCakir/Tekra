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

    let event: GameEvent
    @State private var started = false

    var body: some View {
        ZStack {
            if started {
                BattleContainerView(
                    style: .event,
                    event: event,
                    onExit: {
                        engine.resetBattle()
                        dismiss()
                    },
                    controlPanel: {
                        BattleControlPanel(
                            color: .purple,
                            cards: engine.hand,
                            onPlay: engine.playCard
                        )
                    }
                )
                .transition(.opacity)
            } else {
                eventBriefingView
            }
        }
        .animation(.easeOut(duration: 0.25), value: started)
        .onChange(of: engine.isLevelCleared) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    engine.resetBattle()
                    dismiss()
                }
            }
        }
        .onChange(of: started) { oldValue, newValue in
            if newValue {
                print("🧪 EVENT MODE:", engine.currentMode)
                print("🃏 HAND:", engine.hand.map { $0.id })
            }
        }
        .onAppear {
            print("🧪 EVENT MODE:", engine.currentMode)
            print("🃏 HAND:", engine.hand.map { $0.id })
        }
    }

    // MARK: - EVENT BRIEFING
    private var eventBriefingView: some View {
        VStack(spacing: 28) {

            // Header
            VStack(spacing: 6) {
                Text("WORLD EVENT")
                    .font(.caption.bold())
                    .foregroundColor(.purple)

                Text(event.title.uppercased())
                    .font(
                        .system(size: 26, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.white)
                    .italic()
            }

            // Event Art
            Image(event.background)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            // Beschreibung
            VStack(alignment: .leading, spacing: 12) {
                Text(event.description)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gray)

                Divider().opacity(0.3)

                HStack(spacing: 30) {
                    reward(
                        label: "XP",
                        value: "\(event.rewardXP)",
                        color: .purple
                    )
                    reward(
                        label: "COINS",
                        value: "\(event.rewardCoins)",
                        color: .orange
                    )
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)

            Spacer()

            // Start Button
            Button {
                engine.loadEvent(event)  // ⬅️ setzt Mode + Enemy + drawHand
                started = true  // ⬅️ JETZT erst BattleView zeigen
            } label: {
                Text("START EVENT")
                    .font(
                        .system(size: 18, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(14)
                    .shadow(color: .purple.opacity(0.4), radius: 10)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: - Reward UI
    private func reward(label: String, value: String, color: Color) -> some View
    {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
        }
    }
}

extension GameEngine {
    func resetBattle() {
        isLevelCleared = false
        isPerformingAction = false
        hand.removeAll()
        currentEnemy = nil
        currentWave = nil
        currentRoundIndex = 0
        // If `turnSystem` is private, prefer calling a public API to start the player's turn.
        // Uncomment the next line if you have a public method available, e.g., `startPlayerTurn()`.
        // startPlayerTurn()
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
