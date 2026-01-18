//
//  StoryBattleView.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftData
import SwiftUI

struct StoryBattleView: View {
    // Enhanced logging added to diagnose unlock flow
    @Environment(GameEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss
    @State private var showGameOver = false

    let chapter: StoryChapter  // ✅ HIER
    let stage: StoryStage
    let difficulty: StoryDifficulty

    private var battleState: StoryBattleState { engine.storyBattleState }
    @State private var unlockedFighter: Fighter?

    // MARK: - Accent
    private var accentColor: Color {
        difficulty.color
    }

    // MARK: - BODY
    var body: some View {
        ZStack {

            // =========================
            // FIGHT VIEW
            // =========================
            if battleState == StoryBattleState.fighting
                || battleState == StoryBattleState.unlocking
            {
                BattleContainerView(
                    style: .arcade,
                    onExit: {
                        // ❌ NICHTS TUN
                        // StoryBattleView kontrolliert den Exit
                    },
                    controlPanel: {
                        BattleControlPanel(
                            color: accentColor,
                            cards: engine.hand,
                            onPlay: engine.playCard
                        )
                    }
                )
            }

            // =========================
            // BRIEFING
            // =========================
            if battleState == StoryBattleState.briefing {
                briefingView
                    .transition(.opacity.combined(with: .scale))
            }

            // 💀 GAME OVER OVERLAY
            if showGameOver {
                GameOverOverlayView {
                    engine.storyBattleState = .briefing
                    engine.hardResetBattle()
                    dismiss()
                }
            }

            // =========================
            // REWARD OVERLAY
            // =========================
            if battleState == .rewards {
                StoryRewardOverlayView(
                    xp: stage.rewards.xp,
                    coins: stage.rewards.coins
                ) {
                    proceedAfterRewards()
                }
            }

            // =========================
            // UNLOCK OVERLAY
            // =========================
            if battleState == StoryBattleState.unlocking,
                let fighter = unlockedFighter
            {
                unlockOverlay(fighter)
            }
        }
        .animation(.easeOut(duration: 0.25), value: battleState)
        .onChange(of: engine.isLevelCleared) { old, new in
            print("⚙️ isLevelCleared changed:", old, "->", new)
            handleLevelCleared(old, new)
        }
        .onChange(of: battleState) { _, newValue in
            print("🔁 battleState ->", newValue)
            print(
                "🧠 Engine state: cleared=\(engine.isLevelCleared), wave=\(String(describing: engine.currentWave))"
            )
        }
        .onChange(of: engine.playerHP) { _, newHP in
            if newHP <= 0 && !showGameOver {
                withAnimation(.easeOut(duration: 0.25)) {
                    showGameOver = true
                }
            }
        }
        .onAppear {
            print(
                "👋 StoryBattleView appeared. stage=\(stage.title), difficulty=\(difficulty.title)"
            )
            print(
                "🎯 Initial state: battleState=\(battleState), cleared=\(engine.isLevelCleared)"
            )
        }
        .onAppear {
            print("🃏 EVENT HAND:", engine.hand.map { $0.id })
        }
        .onAppear {
            engine.storyBattleState = .briefing  // 🔥 HARD RESET DES STORY STATES
            print(
                "🧼 StoryBattleState reset to briefing for stage:",
                stage.title
            )
        }
    }

    private var storyDifficultyRating: DifficultyRating {
        let playerLevel = engine.progress?.playerLevel ?? 1
        return DifficultyEvaluator.rating(
            playerLevel: playerLevel,
            recommendedLevel: stage.recommendedLevel
        )
    }

    private var difficultyBadge: some View {
        HStack(spacing: 10) {
            Text("RECOMMENDED LV \(stage.recommendedLevel)")
                .font(.caption.bold())

            Text(storyDifficultyRating.label)
                .font(.caption.bold())
                .foregroundColor(storyDifficultyRating.color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(storyDifficultyRating.color.opacity(0.15))
        .clipShape(Capsule())
    }

    private func proceedAfterRewards() {
        let unlockIDOpt = stage.unlocksCharacter

        // Kein Unlock → direkt raus
        guard
            let unlockID = unlockIDOpt,
            engine.progress?.unlockedCharacters.contains(unlockID) == false,
            let fighter = FighterRegistry.playableCharacters.first(where: {
                $0.id == unlockID
            })
        else {
            exitBattle()
            return
        }

        // Unlock
        engine.unlockCharacterAndSave(unlockID)
        unlockedFighter = fighter
        engine.storyBattleState = .unlocking
    }

    // MARK: - UNLOCK OVERLAY
    private func unlockOverlay(_ fighter: Fighter) -> some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            CharacterUnlockedOverlayView(fighter: fighter) {
                print(
                    "🔓 UNLOCK OVERLAY CONFIRM. fighter=\(fighter.id) \"\(fighter.name)\""
                )
                print(
                    "🔐 Progress unlocked before exit:",
                    engine.progress?.unlockedCharacters ?? []
                )
                exitBattle()
            }
        }
        .onAppear {
            print(
                "🎉 Showing unlock overlay for fighter=\(fighter.id) \"\(fighter.name)\""
            )
        }
    }

    // MARK: - ENGINE CALLBACK
    private func handleLevelCleared(_: Bool, _ cleared: Bool) {
        print(
            "🟢 handleLevelCleared called. cleared=\(cleared), battleState=\(battleState)"
        )
        guard cleared else { return }
        guard battleState == StoryBattleState.fighting else {
            print("⏭️ Ignoring levelCleared because state is not .fighting")
            return
        }
        resolveVictory()
    }

    // MARK: - VICTORY
    private func resolveVictory() {
        print("🏁 resolveVictory() starting…")

        guard let progress = engine.progress else {
            print("⚠️ No progress object found on engine!")
            exitBattle()
            return
        }

        // ✅ STORY REWARDS
        progress.addXP(stage.rewards.xp)
        progress.addCoins(stage.rewards.coins)
        progress.completeStage(stage.id)
        try? engine.modelContext?.save()

        print(
            "🏆 STORY REWARD: +\(stage.rewards.xp) XP, +\(stage.rewards.coins) Coins"
        )
        print("✅ Marked stage as complete:", stage.id)

        // ⬅️ NUR Reward-State setzen
        engine.storyBattleState = .rewards
    }

    // MARK: - BRIEFING VIEW
    private var briefingView: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {

                headerView
                characterPicker
                Spacer()
                startButton
            }
            .padding(24)
        }
    }

    private var startButton: some View {
        let blocked =
            engine.currentPlayer == nil || storyDifficultyRating == .impossible

        return Button(action: startBattle) {
            Text(
                storyDifficultyRating == .impossible
                    ? "LEVEL TOO LOW"
                    : "START FIGHT"
            )
            .font(.system(size: 18, weight: .black, design: .monospaced))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(accentColor)
            .cornerRadius(16)
            .shadow(color: accentColor.opacity(0.5), radius: 12)
            .disabled(storyDifficultyRating == .impossible)
            .opacity(storyDifficultyRating == .impossible ? 0.4 : 1)

        }
        .disabled(blocked)
        .opacity(blocked ? 0.4 : 1)
    }

    private var characterPicker: some View {
        CharacterPickerView()
            .frame(maxHeight: 320)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private var headerView: some View {
        VStack(spacing: 10) {

            // 🧠 STORY DIFFICULTY (Narrativ)
            Text(difficulty.title)
                .font(.caption.bold())
                .foregroundColor(accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(accentColor.opacity(0.15))
                .clipShape(Capsule())

            // 🎯 LEVEL-EMPFEHLUNG (Systemisch)
            difficultyBadge

            Text(stage.title.uppercased())
                .font(.system(size: 30, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("CHOOSE YOUR FIGHTER")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private var resolvedBackground: String {
        stage.background ?? chapter.background
    }

    // MARK: - START
    private func startBattle() {
        print("🚀 startBattle()")

        engine.hardResetBattle()  // 🔥 WICHTIG
        engine.storyBattleState = .fighting

        let enemy = stage.makeEnemy(difficulty: difficulty)

        engine.startArcade(
            wave: ArcadeWave.storySingleEnemy(
                fighter: enemy,
                hpMultiplier: difficulty.hpMultiplier,
                damageMultiplier: difficulty.damageMultiplier,
                recommendedLevel: stage.recommendedLevel,
                background: resolvedBackground
            )
        )

        print("🎬 STAGE BACKGROUND:", resolvedBackground)
    }

    // MARK: - EXIT
    private func exitBattle() {
        engine.storyBattleState = .briefing  // 🔥 WICHTIG
        engine.hardResetBattle()
        dismiss()
        print("🚪 exitBattle() called. Dismissing after cleanup…")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("🧨 hardResetBattle() now…")
            print("⬇️ dismiss()")
        }
    }
}
