//
//  GameEvent.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import Foundation

struct GameEvent: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let enemyFile: String  // z.B. "enemy_boss", "enemy_ninja"
    let rewardExp: Int
}

class EventLoader {
    static func load() -> [GameEvent] {
        guard
            let url = Bundle.main.url(
                forResource: "events",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let events = try? JSONDecoder().decode([GameEvent].self, from: data)
        else { return [] }

        return events
    }
}
