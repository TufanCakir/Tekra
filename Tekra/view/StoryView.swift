//
//  StoryView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct StoryView: View {

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

    @State private var stories: [StoryChapter] = StoryLoader.load()
    @State private var showStorySelect = true

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

            if showStorySelect {
                Color.black.opacity(0.85).ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("STORY MODE")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    ForEach(stories) { story in
                        Button {
                            startStory(story)
                        } label: {
                            Text(story.title)
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

            if levelCleared {
                VStack {
                    Spacer()
                    Text("LEVEL CLEARED")
                        .font(.largeTitle.bold())
                        .foregroundColor(.yellow)
                        .padding(.bottom, 140)
                }
                .transition(.opacity)
            }

            // 🎰 ARCADE FOOTER (nur im Kampf sichtbar)
            if !showStorySelect {
                VStack {
                    Spacer()
                    HStack(spacing: 24) {
                        ActionButton(
                            title: "ATTACK",
                            energy: .fire,
                            action: attack
                        )
                        .frame(maxWidth: .infinity)
                        ActionButton(
                            title: "SWITCH",
                            energy: .ice,
                            action: switchPlayer
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: theme.metal.highlight),
                                        Color(hex: theme.metal.edgeGlow),
                                        Color(hex: theme.metal.shadow),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                    .padding()
                }
            }
        }
        .onAppear(perform: loadGame)
    }

    func loadGame() {
        roster = PlayerRosterLoader.load()
        playerIndex = 0
        enemyIndex = 0
        playerExp = 0
        levelCleared = false
    }

    func startStory(_ story: StoryChapter) {
        showStorySelect = false
        enemies = story.enemies
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

        // Kapitel fertig
        levelCleared = true
        showStorySelect = true
    }
}

#Preview {
    StoryView()
        .environmentObject(
            ThemeManager(theme: ThemeLoader.load())
        )
}
