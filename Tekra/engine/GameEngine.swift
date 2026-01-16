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
    // MARK: - Properties
    var currentMode: GameMode = .event
    var currentWave: ArcadeWave?
    var currentRoundIndex: Int = 0

    var allCards: [Card] = []
    var hand: [Card] = []
    var currentPose = "idle"

    private(set) var gameTime: Double = 0
    var lastUIUpdateTime: Double = 0
    private var cardCooldownTimers: [String: Double] = [:]

    var currentBackground: String = "skybox"
    var p1X: CGFloat = 0
    var enemyScale: CGFloat = 1
    var shakeOffset: CGFloat = 0
    var isFrozen = false
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
    init(mode: GameMode = .arcade) {
        FighterRegistry.loadAll()
        self.allCards = CardLoader.load()
        self.currentMode = mode

        // Setze den ersten verfügbaren Helden als Standard
        if let firstHero = FighterRegistry.playableCharacters.first {
            self.currentPlayer = firstHero
            self.playerHP = firstHero.maxHP
        }

        setupDisplayLink()
    }

    // WICHTIG: Diese Methode wird gerufen, wenn du im Menü einen Helden anklickst
    func selectPlayer(_ fighter: Fighter) {
        self.currentPlayer = fighter
        self.playerHP = fighter.maxHP
        print("👤 Held gewählt: \(fighter.name) (HP: \(fighter.maxHP))")
    }

    // In startRaid oder startArcade wird dann dieser gewählte Held beibehalten
    func startRaid(bossID: String) {
        self.currentMode = .raid
        if let bossData = FighterRegistry.raidBoss(id: bossID) {
            // Wir übergeben KEINEN player im applyMatchSettings, damit der gewählte bleibt
            applyMatchSettings(
                enemy: bossData.toFighter(),
                background: bossData.raidBackground
            )
        }
    }

    // ARCADE STARTEN: Nutzt die arcade.json Struktur
    func startArcade(wave: ArcadeWave) {
        self.currentMode = .arcade  // WICHTIG
        self.currentWave = wave
        self.currentRoundIndex = 0
        loadArcadeRound(index: 0)
    }

    // EVENT STARTEN: Lädt aus der events.json
    func loadEvent(_ event: GameEvent) {
        self.currentMode = .event
        // Wenn in deinem GameEvent nur IDs stehen, suchen wir sie in den anderen JSONs
        // oder das GameEvent Modell muss den Fighter direkt enthalten.

        // Beispiel: Wir nutzen den ersten Gegner-Namen aus dem Event als Bild-ID
        if let firstEnemyID = event.enemies.first {
            let eventFighter = Fighter(
                id: event.id,
                name: event.title,
                imageName: firstEnemyID,  // Nutzt die ID als Asset-Namen
                maxHP: 100,
                attackPower: 20
            )
            applyMatchSettings(
                enemy: eventFighter,
                background: event.background
            )
        }
    }

    private func applyMatchSettings(
        player: Fighter? = nil,
        enemy: Fighter,
        background: String
    ) {
        // Wenn ein neuer Spieler übergeben wird (z.B. durch Auswahlmenü), nimm ihn.
        // Ansonsten behalte den aktuell in der Engine gespeicherten (currentPlayer).
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

    func nextArcadeRound() {
        loadArcadeRound(index: currentRoundIndex + 1)
    }

    // MARK: - Combat & Victory Logic
    private func handleVictory() {
        isLevelCleared = true

        // Dynamische Belohnung berechnen
        let xpGain = (currentMode == .arcade) ? 75 : 50
        let coinGain = (currentMode == .arcade) ? 20 : 10

        // Speichern in SwiftData via PlayerProgress Modell
        progress?.addXP(xpGain)
        progress?.addCoins(coinGain)

        print("🏆 Sieg! +\(xpGain) XP und +\(coinGain) Coins erhalten.")
        // Enemy victory handling could be added here similarly
    }

    private func triggerHitEffects(damage: CGFloat, toEnemy: Bool = true) {
        isFrozen = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.isFrozen = false
        }

        if toEnemy {
            enemyHP = max(enemyHP - damage, 0)
            enemyScale = 1.15
            withAnimation(.spring(duration: 0.2)) { self.enemyScale = 1.0 }
        } else {
            playerHP = max(playerHP - damage, 0)
        }

        let shakeFrames: [CGFloat] = [10, -8, 6, -4, 2, 0]
        for (i, offset) in shakeFrames.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                self.shakeOffset = offset
            }
        }

        // Victory checks
        if enemyHP <= 0 { handleVictory() }
    }

    // MARK: - Helpers
    func isCardReady(_ card: Card) -> Bool {
        gameTime >= (cardCooldownTimers[card.id] ?? 0)
    }

    func cooldownProgress(for card: Card) -> Double {
        guard let endTime = cardCooldownTimers[card.id], card.cooldown > 0
        else { return 1.0 }
        let remaining = max(endTime - gameTime, 0)
        return min(max(1.0 - (remaining / card.cooldown), 0.0), 1.0)
    }

    func playCard(_ card: Card) {
        guard isCardReady(card), !isPerformingAction, !isLevelCleared else {
            return
        }
        isPerformingAction = true
        cardCooldownTimers[card.id] = gameTime + card.cooldown
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
                guard !self.isLevelCleared, self.enemyHP > 0 else { return }
                let retaliation = max(5, card.damage * 0.3)
                self.triggerHitEffects(damage: retaliation, toEnemy: false)
            }
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
    }

    func setTheme(_ id: String) {
        self.activeThemeID = id
        progress?.updateTheme(newID: id)
        try? modelContext?.save()
    }
}
