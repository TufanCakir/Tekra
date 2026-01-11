//
//  Fighter.swift
//  Tekra
//
//  Created by Tufan Cakir on 10.01.26.
//

import Foundation

struct Fighter: Codable, Identifiable {
    let id: Int
    let name: String
    let image: String
    let maxHP: CGFloat
    let attack: Int
}

class PlayerRosterLoader {
    static func load() -> [Fighter] {
        print("🟦 Loading players.json...")

        guard
            let url = Bundle.main.url(
                forResource: "players",
                withExtension: "json"
            )
        else {
            print("❌ players.json NOT FOUND in bundle")
            return []
        }

        guard let data = try? Data(contentsOf: url) else {
            print("❌ Could not read players.json")
            return []
        }

        guard
            let fighters = try? JSONDecoder().decode([Fighter].self, from: data)
        else {
            print("❌ JSON decode failed for players.json")
            return []
        }

        print("✅ Loaded Players:", fighters.map { $0.name })
        return fighters
    }
}

class EnemyWaveLoader {

    static func load(file: String) -> [Fighter] {
        print("🟥 Loading \(file).json...")

        guard
            let url = Bundle.main.url(forResource: file, withExtension: "json")
        else {
            print("❌ \(file).json NOT FOUND in bundle")
            return []
        }

        guard let data = try? Data(contentsOf: url) else {
            print("❌ Could not read \(file).json")
            return []
        }

        guard
            let enemies = try? JSONDecoder().decode([Fighter].self, from: data)
        else {
            print("❌ JSON decode failed for \(file).json")
            return []
        }

        print("✅ Loaded Enemies:", enemies.map { $0.name })
        return enemies
    }
}
