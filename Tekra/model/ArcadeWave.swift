//
//  ArcadeWave.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import Foundation

struct ArcadeWave: Codable, Identifiable {
    let id: Int
    let title: String
    let rounds: [[ArcadeEnemy]]  // Ein Array von Runden, jede Runde hat ein Array von Gegnern
}

struct ArcadeEnemy: Codable {
    let id: Int
    let name: String
    let image: String
    let maxHP: Double
    let attack: Int

    // Wandelt den Arcade-Eintrag in das Standard-Fighter-Modell um
    func toFighter() -> Fighter {
        Fighter(
            id: "arcade_\(id)",
            name: name,
            imageName: image,
            maxHP: CGFloat(maxHP),
            attackPower: CGFloat(attack)
        )
    }
}

struct ArcadeResponse: Codable {
    let waves: [ArcadeWave]
}
/// Story-Hilfswave mit genau einem Gegner
extension ArcadeWave {

    /// Story-Hilfswave mit genau einem Gegner
    /// - Parameters:
    ///   - enemyID: ID aus Story / Registry
    ///   - hpMultiplier: Skalierung der Lebenspunkte (z. B. 1.5 für Boss)
    ///   - damageMultiplier: Skalierung des Schadens
    static func singleEnemy(
        _ enemyID: String,
        hpMultiplier: CGFloat = 1.0,
        damageMultiplier: CGFloat = 1.0
    ) -> ArcadeWave {

        let enemy =
            FighterRegistry.enemy(id: enemyID)
            ?? Fighter(
                id: "fallback",
                name: "UNKNOWN",
                imageName: "unknown_enemy",
                maxHP: 50,
                attackPower: 5
            )

        let scaledHP = max(1, enemy.maxHP * hpMultiplier)
        let scaledAttack = max(1, enemy.attackPower * damageMultiplier)

        let arcadeEnemy = ArcadeEnemy(
            id: Int.random(in: 10_000...99_999),
            name: enemy.name,
            image: enemy.imageName,
            maxHP: Double(scaledHP),
            attack: Int(scaledAttack)
        )

        return ArcadeWave(
            id: Int.random(in: 1000...9999),
            title: "Story Battle",
            rounds: [[arcadeEnemy]]
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
            print("❌ arcade.json nicht gefunden oder lesbar")
            return []
        }

        do {
            // Falls dein JSON direkt ein Array ist, nutzt man [ArcadeWave].self
            // Da dein JSON mit [ beginnt, ist es ein direktes Array:
            return try JSONDecoder().decode([ArcadeWave].self, from: data)
        } catch {
            print("❌ Arcade Decode Fehler: \(error)")
            return []
        }
    }
}
