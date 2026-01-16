//
//  Card.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import Foundation
import SwiftUI

struct Card: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let actionImage: String
    let damage: CGFloat
    let type: CardType
    let colorHex: String
    let cooldown: Double

    // lastUsed wird ignoriert (CodingKeys), aber wir können es im init initialisieren
    var lastUsed: Date = .distantPast

    enum CodingKeys: String, CodingKey {
        case id, title, actionImage, damage, type, colorHex, cooldown
    }

    // Direktzugriff auf Farbe (bereits gut, aber hier sicherheitshalber mit Fallback)
    var uiColor: Color {
        Color(hex: colorHex)
    }

    enum CardType: String, Codable {
        case punch, kick, special, run

        // Verhindert Crash, falls ein unbekannter Typ im JSON steht
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            self = CardType(rawValue: raw) ?? .punch
        }
    }
}

// MARK: - Optimierter Loader
class CardLoader {
    static func load() -> [Card] {
        // Nutzt main bundle url sicher
        guard
            let url = Bundle.main.url(
                forResource: "cards",
                withExtension: "json"
            )
        else {
            print("❌ Fehler: cards.json fehlt.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // Falls das JSON-Format (z.B. Datumsformate) komplexer wird, hier konfigurieren
            let cards = try decoder.decode([Card].self, from: data)

            // Optional: Sortierung nach Schaden oder Typ beim Laden
            return cards.sorted { $0.damage < $1.damage }

        } catch let decodingError as DecodingError {
            // Detailliertere Fehlerausgabe für Entwickler
            handle(decodingError)
            return []
        } catch {
            print("❌ Unbekannter Fehler: \(error)")
            return []
        }
    }

    private static func handle(_ error: DecodingError) {
        switch error {
        case .keyNotFound(let key, _):
            print("🔑 Key '\(key.stringValue)' fehlt im JSON.")
        case .typeMismatch(let type, let context):
            print("⚠️ Typ-Fehler: \(type) bei \(context.codingPath).")
        case .valueNotFound(let type, _):
            print("🚫 Wert vom Typ \(type) ist null.")
        case .dataCorrupted(_): print("🧨 JSON-Daten sind beschädigt.")
        @unknown default: print("❓ Unbekannter Decoding-Fehler.")
        }
    }
}
