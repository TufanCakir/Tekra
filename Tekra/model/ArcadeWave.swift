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
