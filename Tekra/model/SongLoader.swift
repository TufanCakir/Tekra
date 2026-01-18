//
//  SongLoader.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import Foundation

enum SongLoader {
    static func load() -> SongLibrary? {
        guard
            let url = Bundle.main.url(
                forResource: "songs",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url)
        else {
            print("❌ songs.json nicht gefunden")
            return nil
        }

        do {
            return try JSONDecoder().decode(SongLibrary.self, from: data)
        } catch {
            print("❌ Song decode error:", error)
            return nil
        }
    }
}
