//
//  GameEngine.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import GameplayKit
import Observation
import SwiftData
import SwiftUI

// Placeholder to satisfy compilation if GameProgress exists elsewhere, remove if duplicated
struct GameProgress {
    mutating func updateTheme(newID: String) {}
}

enum GameMode {
    case arcade, raid, event
}

@Observable @MainActor
class GameEngine {
    private let combatSystem = CombatSystem()
    private let cardSystem = CardSystem()
    private let progressionSystem = ProgressionSystem()
    private let effectSystem = EffectSystem()
    private let turnSystem = TurnSystem()
    private let enemyAI = EnemyAI()

    var enemyScale: CGFloat { effectSystem.enemyScale }
    var shakeOffset: CGFloat { effectSystem.shakeOffset }
    var isFrozen: Bool { effectSystem.isFrozen }

    // MARK: - Properties
    var currentMode: GameMode = .event
    var currentWave: ArcadeWave?
    var currentRoundIndex: Int = 0

    var allCards: [Card] = []
    var hand: [Card] = []
    var currentPose = "idle"

    private(set) var gameTime: Double = 0
    var lastUIUpdateTime: Double = 0

    var currentBackground: String = "skybox"
    var p1X: CGFloat = 0
    private let playerEntity = GKEntity()

    var playerHP: CGFloat = 100
    var enemyHP: CGFloat = 100  // will be dynamically initialized in applyMatchSettings
    var isLevelCleared = false
    var isPerformingAction = false

    var currentPlayer: Fighter?
    var currentEnemy: Fighter?

    // MARK: - Persistence Link
    private var modelContext: ModelContext?
    var activeThemeID: String = ""
    var progress: PlayerProgress?  // Nutzt jetzt dein echtes SwiftData Modell

    // MARK: - Initialization
    private var modeController: ModeController!

    init(mode: GameMode = .arcade) {
        FighterRegistry.loadAll()
        self.allCards = CardLoader.load()
        self.currentMode = mode

        if let firstHero = FighterRegistry.playableCharacters.first {
            self.currentPlayer = firstHero
            self.playerHP = firstHero.maxHP
        }

        setupDisplayLink()

        // ✅ JETZT ist self vollständig initialisiert
        self.modeController = ModeController(engine: self)
    }

    // WICHTIG: Diese Methode wird gerufen, wenn du im Menü einen Helden anklickst
    func selectPlayer(_ fighter: Fighter) {
        currentPlayer = fighter
        playerHP = fighter.maxHP
        progress?.selectedFighterID = fighter.id
    }

    func unlockCharacterAndSave(_ id: String) {
        progress?.unlockCharacter(id)
        try? modelContext?.save()
    }

    func startArcade(wave: ArcadeWave) {
        modeController.startArcade(wave: wave)
    }

    func startRaid(bossID: String) {
        modeController.startRaid(bossID: bossID)
    }

    func loadEvent(_ event: GameEvent) {
        modeController.startEvent(event)
    }

    func nextArcadeRound() {
        modeController.nextArcadeRound()
    }

    private func applyMatchSettings(
        player: Fighter? = nil,
        enemy: Fighter,
        background: String
    ) {
        // ⬇️ HIER rein
        enemyAI.configurePattern(for: enemy)

        if let player = player {
            self.currentPlayer = player
        }

        self.currentEnemy = enemy
        self.playerHP = self.currentPlayer?.maxHP ?? 100
        self.enemyHP = enemy.maxHP
        self.currentBackground = background

        // Reset State
        self.isLevelCleared = false
        self.isPerformingAction = false
        self.currentPose = "idle"
        self.p1X = 0
        self.hand = Array(allCards.shuffled().prefix(3))
    }

    func loadArcadeRound(index: Int) {
        guard let wave = currentWave, wave.rounds.indices.contains(index) else {
            print("🏁 Welle komplett abgeschlossen!")
            self.isLevelCleared = true
            return
        }

        // Wir nehmen den Gegner der aktuellen Runde
        if let enemyData = wave.rounds[index].first {
            let arcadeFighter = enemyData.toFighter()

            // Reset der Arena-Werte (Hintergrund bleibt, kann bei Bedarf pro Wave/Runde erweitert werden)
            self.applyMatchSettings(
                enemy: arcadeFighter,
                background: self.currentBackground
            )
            self.currentRoundIndex = index

            print("🕹 Lade Runde \(index + 1): \(arcadeFighter.name)")
        }
    }

    // MARK: - Combat & Victory Logic
    private func handleVictory() {
        isLevelCleared = true
        progressionSystem.applyVictoryRewards(
            mode: currentMode,
            progress: progress
        )
    }

    func syncSelectedCharacterFromProgress() {
        guard
            let id = progress?.selectedFighterID,
            let fighter = FighterRegistry.playableCharacters.first(where: {
                $0.id == id
            })
        else { return }

        currentPlayer = fighter
    }

    private func triggerHitEffects(
        damage: CGFloat,
        toEnemy: Bool = true
    ) {
        var defeated = false

        if toEnemy {
            // 🔥 HP-Änderung sauber animieren
            withAnimation(.easeOut(duration: 0.25)) {
                defeated = combatSystem.applyDamage(
                    damage: damage,
                    to: &enemyHP
                )
            }

            enemyAI.updatePhaseIfNeeded(currentHP: enemyHP)
            effectSystem.hitEnemy()
        } else {
            withAnimation(.easeOut(duration: 0.25)) {
                defeated = combatSystem.applyDamage(
                    damage: damage,
                    to: &playerHP
                )
            }
        }

        // 📸 Erst Shake
        effectSystem.shakeCamera()

        // ❄️ Dann kurzer Hit-Stop (minimal verzögert)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.effectSystem.hitStop()
        }

        // 🏆 Victory nur einmal & sauber
        if toEnemy && defeated {
            isPerformingAction = false
            turnSystem.lock()  // 🔒 GANZ WICHTIG
            handleVictory()
        }
    }

    func softResetBattle() {
        isLevelCleared = false
        isPerformingAction = false
    }

    func hardResetBattle() {
        softResetBattle()
        hand.removeAll()
        currentEnemy = nil
        currentWave = nil
        currentRoundIndex = 0
    }

    // MARK: - Helpers
    func isCardReady(_ card: Card) -> Bool {
        cardSystem.isReady(card: card, time: gameTime)
    }

    func cooldownProgress(for card: Card) -> Double {
        cardSystem.progress(card: card, time: gameTime)
    }

    func playCard(_ card: Card) {
        guard
            turnSystem.canPlayerAct(),
            cardSystem.isReady(card: card, time: gameTime),
            !isPerformingAction,
            !isLevelCleared
        else { return }

        turnSystem.lock()
        isPerformingAction = true

        cardSystem.play(card: card, time: gameTime)
        runAttackSequence(card)
        replaceCardInHand(card)
    }

    private func runAttackSequence(_ card: Card) {
        currentPose = "windup"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.currentPose = card.type.rawValue
            self.triggerHitEffects(damage: card.damage, toEnemy: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.currentPose = "idle"
                    self.isPerformingAction = false
                }
            }
            // Optional: simple counter-attack logic based on card type cooldown to demonstrate dynamic damage flow
            DispatchQueue.main.asyncAfter(
                deadline: .now() + max(0.4, card.cooldown * 0.5)
            ) {
                guard !self.isLevelCleared, self.enemyHP > 0 else {
                    self.turnSystem.startPlayerTurn()  // 🔥 WICHTIG
                    return
                }

                self.turnSystem.startEnemyTurn()
                self.performEnemyTurn()
            }
        }
    }

    private func performEnemyTurn() {
        guard let enemy = currentEnemy else { return }

        let action = enemyAI.chooseAction(
            enemy: enemy,
            playerHP: playerHP
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            switch action {

            case .basicAttack(let multiplier):
                self.triggerHitEffects(
                    damage: enemy.attackPower * multiplier,
                    toEnemy: false
                )

            case .heavyAttack:
                self.triggerHitEffects(
                    damage: enemy.attackPower * 1.6,
                    toEnemy: false
                )

            case .wait:
                break

            case .enrage:
                // später: Buff-System
                break
            }

            self.turnSystem.startPlayerTurn()
        }
    }

    private func replaceCardInHand(_ card: Card) {
        guard let index = hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        withAnimation(.spring()) {
            hand.remove(at: index)
            let pool = allCards.filter { c in
                !hand.contains(where: { $0.id == c.id })
            }
            hand.insert(pool.randomElement() ?? allCards[0], at: index)
        }
    }

    private func setupDisplayLink() {
        let dl = CADisplayLink(target: self, selector: #selector(updateLoop))
        dl.add(to: .main, forMode: .common)
    }

    @objc private func updateLoop(_ link: CADisplayLink) {
        gameTime += link.duration
        lastUIUpdateTime = gameTime
    }

    func setupDatabase(context: ModelContext, playerProgress: PlayerProgress) {
        self.modelContext = context
        self.progress = playerProgress
        syncSelectedCharacterFromProgress()
    }

    func setTheme(_ id: String) {
        self.activeThemeID = id
        progress?.updateTheme(newID: id)
        try? modelContext?.save()
    }
}
