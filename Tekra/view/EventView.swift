//
//  EventView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct EventView: View {

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

    @State private var events: [GameEvent] = []
    @State private var currentEventIndex = 0
    @State private var showEventSelect = true

    var currentEvent: GameEvent? {
        events.indices.contains(currentEventIndex)
            ? events[currentEventIndex] : nil
    }

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

                    // Buttons
                    HStack {
                        ActionButton(
                            title: "ATTACK",
                            energy: .fire,
                            action: attack
                        )
                        ActionButton(
                            title: "SWITCH",
                            energy: .ice,
                            action: switchPlayer
                        )
                    }
                    .disabled(showEventSelect)
                    .opacity(showEventSelect ? 0.4 : 1)
                    .font(.system(size: 20, weight: .bold))
                    .frame(height: 44)
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                }
                .background(
                    Image("skybox")
                        .resizable()
                        .scaledToFill()
                )
            }

            if showEventSelect {
                Color.black.opacity(0.85).ignoresSafeArea()

                EventSelectView(events: events) { index in
                    startEvent(index)
                }
                .transition(.scale)
            }

            if levelCleared {
                Text("LEVEL CLEARED")
                    .font(.largeTitle.bold())
                    .foregroundColor(.yellow)
            }
        }
        .onAppear(perform: loadGame)
    }

    // MARK: Game Logic
    func loadGame() {

        roster = PlayerRosterLoader.load()
        events = EventLoader.load()

        playerIndex = 0
        enemyIndex = 0
        playerExp = 0
        levelCleared = false

        if let firstEvent = events.first {
            enemies = EnemyWaveLoader.load(file: firstEvent.enemyFile)
            enemyHP = enemies.first?.maxHP ?? 0
        } else {
            enemies = []
            enemyHP = 0
            levelCleared = true
            showEventSelect = true
        }
    }

    func startEvent(_ index: Int) {
        showEventSelect = false
        currentEventIndex = index

        let event = events[index]
        enemies = EnemyWaveLoader.load(file: event.enemyFile)
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

        // Event vorbei → nächstes Event laden
        let nextEventIndex = currentEventIndex + 1
        if events.indices.contains(nextEventIndex) {
            currentEventIndex = nextEventIndex
            let event = events[currentEventIndex]

            enemies = EnemyWaveLoader.load(file: event.enemyFile)
            enemyIndex = 0
            enemyHP = enemies.first?.maxHP ?? 0
            return
        }

        levelCleared = true
        showEventSelect = true
    }
}

#Preview {
    EventView()
        .environmentObject(
            ThemeManager(theme: ThemeLoader.load())
        )
}
