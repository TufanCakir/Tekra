//
//  ThemeLoader.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import Foundation

enum ThemeLoader {

    static func load(named name: String = "theme") -> Theme {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "json")
        else {
            fatalError("❌ Theme JSON '\(name).json' not found in Bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(Theme.self, from: data)
        } catch {
            fatalError("❌ Failed to decode theme '\(name).json': \(error)")
        }
    }
}
