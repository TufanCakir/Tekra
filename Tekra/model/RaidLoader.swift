//
//  RaidLoader.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

enum RaidLoader {
    static func load() -> [RaidBoss] {
        guard
            let url = Bundle.main.url(
                forResource: "raid",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url)
        else {
            print("❌ raid.json nicht gefunden")
            return []
        }
        do {
            // Die Klammern müssen den Typ umschließen, und .self steht am Ende
            return try JSONDecoder().decode([RaidBoss].self, from: data)
        } catch {
            print("❌ Raid Decode Error: \(error)")
            return []
        }
    }
}
