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
            )
        else {
            print("❌ RaidLoader: raid.json nicht im Bundle gefunden")
            return []
        }

        print("📂 RaidLoader: Lade Datei:", url.lastPathComponent)

        guard let data = try? Data(contentsOf: url) else {
            print("❌ RaidLoader: Konnte raid.json nicht lesen")
            return []
        }

        print("📦 RaidLoader: \(data.count) Bytes geladen")

        do {
            let bosses = try JSONDecoder().decode([RaidBoss].self, from: data)
            print(
                "✅ RaidLoader: \(bosses.count) Raid-Bosse erfolgreich geladen"
            )

            for boss in bosses {
                print(
                    """
                    🧠 RaidBoss geladen:
                    - id: \(boss.id)
                    - name: \(boss.name)
                    - image: \(boss.imageName)
                    - HP: \(boss.maxHP)
                    - ATK: \(boss.attackPower)
                    - poses: \(boss.availablePoses)
                    """
                )
            }

            return bosses

        } catch {
            print("❌ RaidLoader: Decode FEHLER")
            print("➡️ Error:", error)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 raid.json Inhalt:")
                print(jsonString)
            } else {
                print("❌ raid.json konnte nicht als String gelesen werden")
            }

            return []
        }
    }
}
