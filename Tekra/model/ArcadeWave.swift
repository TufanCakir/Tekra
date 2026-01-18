//
//  ArcadeWave.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import CoreGraphics
import Foundation

struct ArcadeWave: Identifiable {
    let id: Int
    let title: String
    let background: String  // 👈 3.
    let rounds: [[ArcadeEnemy]]  // 👈 4.
    let recommendedLevel: Int  // 👈 5.
    let rewards: StoryRewards  // ✅ NEU
}

struct ArcadeEnemy: Identifiable, Codable {
    let id: Int
    let enemyID: String
    let name: String
    let image: String
    let maxHP: CGFloat
    let attack: CGFloat
    let hpMultiplier: CGFloat
    let damageMultiplier: CGFloat

    // Derived fighter built from this enemy's base stats and multipliers
    var fighter: Fighter {
        Fighter(
            id: enemyID,
            name: name,
            imageName: image,
            maxHP: maxHP * hpMultiplier,
            attackPower: attack * damageMultiplier,
            availablePoses: ["idle", "punch", "kick", "special"],
            cardOwners: ["generic"]
        )
    }
}

struct ArcadeWaveDTO: Codable {
    let id: Int
    let title: String
    let background: String  // 👈 NEU
    let rounds: [[ArcadeEnemyDTO]]
    let recommendedLevel: Int  // ⬅️ NEU
    let rewards: StoryRewards  // ✅ NEU
}

struct ArcadeEnemyDTO: Codable {
    let enemyID: String
    let name: String
    let image: String
    let baseHP: CGFloat
    let baseAttack: CGFloat
    let hpMultiplier: CGFloat
    let damageMultiplier: CGFloat
}

extension ArcadeWave {

    /// Story-Hilfswave (1 Gegner, 1 Runde)
    static func storySingleEnemy(
        fighter: Fighter,
        hpMultiplier: CGFloat,
        damageMultiplier: CGFloat,
        recommendedLevel: Int,
        background: String,  // ✅ NEU
        rewards: StoryRewards = .init(xp: 0, coins: 0)
    ) -> ArcadeWave {

        let scaledFighter = Fighter(
            id: fighter.id,
            name: fighter.name,
            imageName: fighter.imageName,
            maxHP: fighter.maxHP * hpMultiplier,
            attackPower: fighter.attackPower * damageMultiplier,
            availablePoses: fighter.availablePoses,
            cardOwners: []
        )

        let enemy = ArcadeEnemy(
            id: Int.random(in: 10_000...99_999),
            enemyID: scaledFighter.id,
            name: scaledFighter.name,
            image: scaledFighter.imageName,
            maxHP: scaledFighter.maxHP,
            attack: scaledFighter.attackPower,
            hpMultiplier: 1.0,
            damageMultiplier: 1.0
        )

        return ArcadeWave(
            id: Int.random(in: 1_000...9_999),
            title: "Story Battle",
            background: background,  // ✅ 3.
            rounds: [[enemy]],  // ✅ 4.
            recommendedLevel: recommendedLevel,
            rewards: rewards,
        )
    }
}

enum ArcadeLoader {

    static func load() -> [ArcadeWave] {
        guard
            let url = Bundle.main.url(
                forResource: "arcade",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url)
        else {
            print("❌ arcade.json nicht gefunden")
            return []
        }
        print("📦 Loading arcade.json…")

        do {
            let dtoWaves = try JSONDecoder().decode(
                [ArcadeWaveDTO].self,
                from: data
            )

            return dtoWaves.map { dto in
                // Build rounds by transforming each DTO enemy into an ArcadeEnemy using registry base stats
                let rounds: [[ArcadeEnemy]] = dto.rounds.map { round in
                    round.map { enemyDTO in
                        // Get base fighter from registry or fallback
                        let base =
                            FighterRegistry.enemy(id: enemyDTO.enemyID)
                            ?? Fighter(
                                id: "fallback",
                                name: "UNKNOWN",
                                imageName: "unknown_enemy",
                                maxHP: 50,
                                attackPower: 10,
                                availablePoses: ["idle"],
                                cardOwners: []
                            )

                        // Apply multipliers from DTO to base stats
                        let scaledMaxHP =
                            enemyDTO.baseHP * enemyDTO.hpMultiplier
                        let scaledAttack =
                            enemyDTO.baseAttack * enemyDTO.damageMultiplier

                        return ArcadeEnemy(
                            id: Int.random(in: 10_000...99_999),
                            enemyID: enemyDTO.enemyID,
                            name: enemyDTO.name.isEmpty
                                ? base.name : enemyDTO.name,
                            image: enemyDTO.image.isEmpty
                                ? base.imageName : enemyDTO.image,
                            maxHP: scaledMaxHP,
                            attack: scaledAttack,
                            hpMultiplier: 1.0,
                            damageMultiplier: 1.0
                        )
                    }
                }

                return ArcadeWave(
                    id: dto.id,
                    title: dto.title,
                    background: dto.background,  // 🔥 aus JSON
                    rounds: rounds,
                    recommendedLevel: dto.recommendedLevel,
                    rewards: dto.rewards  // ✅ WICHTIG
                )
            }

        } catch {
            print("❌ Arcade Decode Fehler:", error)
            return []
        }
    }
}
