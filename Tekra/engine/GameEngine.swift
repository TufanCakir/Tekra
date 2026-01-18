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

enum StoryBattleState {
    case briefing
    case fighting
    case rewards  // ⬅️ NEU
    case unlocking
}

@Observable @MainActor
class GameEngine {

    private let combatSystem = CombatSystem()
    private let cardSystem = CardSystem()
    private let progressionSystem = ProgressionSystem()
    private let effectSystem = EffectSystem()
    private let turnSystem = TurnSystem()
    private let enemyAI = EnemyAI()
    var storyBattleState: StoryBattleState = .briefing

    var enemyScale: CGFloat { effectSystem.enemyScale }
    var shakeOffset: CGFloat { effectSystem.shakeOffset }
    var isFrozen: Bool { effectSystem.isFrozen }
    private var allowedCards: [Card] = []

    // MARK: - Properties
    var currentMode: GameMode = .event
    var currentWave: ArcadeWave?
    var currentRoundIndex: Int = 0
    var isPlayerDefeated: Bool {
        playerHP <= 0
    }
    var allCards: [Card] = []
    var hand: [Card] = []
    var currentPose = "idle"
    var enemyPose: String = "idle"

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
    var modelContext: ModelContext?
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

    func spriteName(for fighter: Fighter, pose: String) -> String {
        // 1. Ungültige Posen abfangen
        let resolvedPose: String
        if fighter.availablePoses.contains(pose) {
            resolvedPose = pose
        } else {
            resolvedPose = "idle"
        }

        // 2. Base-Name
        let base = fighter.imageName

        // 3. Sprite-Kandidat
        let candidate = "\(base)_\(resolvedPose)"

        if UIImage(named: candidate) != nil {
            return candidate
        }

        // 4. Finaler Fallback (NUR EINMAL idle)
        let idle = "\(base)_idle"
        if UIImage(named: idle) != nil {
            return idle
        }

        // 5. Hard fallback (damit nichts crasht)
        print("🧩 Missing asset:", candidate)
        return base
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

    func applyMatchSettings(
        enemy: Fighter,
        background: String
    ) {
        guard let player = currentPlayer else { return }

        let playerLevel = progress?.playerLevel ?? 1

        let scaledHP = EnemyScaling.scaledHP(
            baseHP: enemy.maxHP,
            playerLevel: playerLevel,
            mode: currentMode
        )

        let scaledAttack = EnemyScaling.scaledAttack(
            baseAttack: enemy.attackPower,
            playerLevel: playerLevel,
            mode: currentMode
        )

        let scaledEnemy = Fighter(
            id: enemy.id,
            name: enemy.name,
            imageName: enemy.imageName,
            maxHP: scaledHP,
            attackPower: scaledAttack,
            availablePoses: enemy.availablePoses,
            cardOwners: enemy.cardOwners
        )

        enemyAI.configurePattern(for: scaledEnemy)

        self.currentEnemy = scaledEnemy
        let scaledPlayerHP = PlayerScaling.scaledHP(
            baseHP: player.maxHP,
            playerLevel: playerLevel
        )

        self.playerHP = scaledPlayerHP
        self.enemyHP = scaledEnemy.maxHP
        self.currentBackground = background

        isLevelCleared = false
        isPerformingAction = false
        currentPose = "idle"
        enemyPose = "idle"
        p1X = 0

        drawHand()
    }

    func drawHand() {
        print("🃏 drawHand() called")

        guard let player = currentPlayer else {
            print("❌ drawHand: currentPlayer == nil")
            return
        }

        print("👤 Player:", player.id)
        print("👤 Player cardOwners:", player.cardOwners)

        print("📦 All cards loaded:", allCards.count)
        print("📦 All card owners:", Set(allCards.map { $0.owner }))

        allowedCards = allCards.filter { card in
            let allowed = player.cardOwners.contains(card.owner)
            if allowed {
                print("✅ Card allowed:", card.id, "owner:", card.owner)
            }
            return allowed
        }

        if allowedCards.isEmpty {
            print(
                """
                ⚠️ NO ALLOWED CARDS FOUND
                Player owners: \(player.cardOwners)
                Card owners: \(Set(allCards.map { $0.owner }))
                Applying GENERIC fallback
                """
            )

            allowedCards = allCards.filter { card in
                player.cardOwners.contains(card.owner)
                    || (currentMode == .event && card.owner == "generic")
            }
            print("🔁 Generic fallback cards:", allowedCards.map { $0.id })
        }

        hand = Array(
            Array(Set(allowedCards))  // 🔑 deduplizieren
                .shuffled()
                .prefix(3)
        )
        print("🖐 Final hand:", hand.map { $0.id })
    }

    func loadArcadeRound(index: Int) {
        guard let wave = currentWave, wave.rounds.indices.contains(index) else {
            isLevelCleared = true
            return
        }

        if let enemyData = wave.rounds[index].first {
            let arcadeFighter = enemyData.fighter

            applyMatchSettings(
                enemy: arcadeFighter,
                background: currentBackground
            )

            currentRoundIndex = index
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

            self.currentPose = card.poseName

            let playerLevel = self.progress?.playerLevel ?? 1

            let scaledDamage = PlayerScaling.scaledAttack(
                baseAttack: card.damage,
                playerLevel: playerLevel
            )

            self.triggerHitEffects(damage: scaledDamage, toEnemy: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.currentPose = "idle"
                    self.isPerformingAction = false
                }

                // 👹 ENEMY TURN STARTEN
                guard !self.isLevelCleared else {
                    self.turnSystem.startPlayerTurn()
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

        enemyPose = "windup"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {

            switch action {

            case .basicAttack:
                self.enemyPose = "punch"
                self.triggerHitEffects(
                    damage: enemy.attackPower,
                    toEnemy: false
                )

            case .heavyAttack:
                self.enemyPose = "kick"
                self.triggerHitEffects(
                    damage: enemy.attackPower * 1.6,
                    toEnemy: false
                )

            case .enrage:
                self.enemyPose = "special"

            case .wait:
                self.enemyPose = "idle"
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.enemyPose = "idle"
                self.turnSystem.startPlayerTurn()
            }
        }
    }

    private func replaceCardInHand(_ card: Card) {
        guard let index = hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        let existingIDs = Set(hand.map { $0.id })
        let pool = allowedCards.filter { !existingIDs.contains($0.id) }

        // 🔒 WICHTIG: Kein Ersatz möglich → einfach drin lassen
        guard let replacement = pool.randomElement() else {
            print("⚠️ No unique replacement available – keeping hand")
            return
        }

        withAnimation(.spring()) {
            hand[index] = replacement
        }
    }

    private func setupDisplayLink() {
        let dl = CADisplayLink(target: self, selector: #selector(updateLoop))
        dl.add(to: .main, forMode: .common)
    }

    @objc private func updateLoop(_ link: CADisplayLink) {
        gameTime += link.duration
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
