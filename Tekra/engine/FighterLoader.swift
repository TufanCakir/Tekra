//
//  FighterLoader.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

enum FighterLoader {

    static func load(file: String) -> [Fighter] {
        guard
            let url = Bundle.main.url(forResource: file, withExtension: "json")
        else {
            print("❌ \(file).json not found")
            return []
        }

        guard let data = try? Data(contentsOf: url) else {
            print("❌ Could not read \(file).json")
            return []
        }

        do {
            return try JSONDecoder().decode([Fighter].self, from: data)
        } catch {
            print("❌ Decode error in \(file).json:", error)
            return []
        }
    }
}
