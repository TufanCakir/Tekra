//
//  EventLoader.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

enum EventLoader {
    static func load() -> [GameEvent] {
        guard
            let url = Bundle.main.url(
                forResource: "events",
                withExtension: "json"
            )
        else {
            print("❌ events.json nicht gefunden")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(
                EventResponse.self,
                from: data
            )
            return response.events
        } catch {
            print("❌ Fehler beim Dekodieren der Events: \(error)")
            return []
        }
    }
}
