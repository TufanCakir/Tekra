//
//  ArcadeWave.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//
import Foundation

struct ArcadeWave: Identifiable, Codable {
    let id: Int
    let title: String
    let rounds: [[Fighter]]   // ← Runden mit eigenen Gegnern
}


struct ArcadeLoader {
    static func load() -> [ArcadeWave] {
        guard let url = Bundle.main.url(forResource: "arcade", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let waves = try? JSONDecoder().decode([ArcadeWave].self, from: data) else {
            return []
        }
        return waves
    }
}
