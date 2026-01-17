//
//  StoryLoader.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import Foundation

final class StoryLoader {

    static func load() -> [StoryChapter] {

        print("📖 StoryLoader: Lade story.json …")

        // 1. Datei finden
        guard
            let url = Bundle.main.url(
                forResource: "story",
                withExtension: "json"
            )
        else {
            print("❌ StoryLoader ERROR: story.json NICHT im Bundle gefunden")
            return []
        }

        print("✅ StoryLoader: story.json gefunden → \(url.lastPathComponent)")

        // 2. Datei lesen
        let data: Data
        do {
            data = try Data(contentsOf: url)
            print(
                "✅ StoryLoader: story.json erfolgreich gelesen (\(data.count) Bytes)"
            )
        } catch {
            print("❌ StoryLoader ERROR: Kann story.json nicht lesen → \(error)")
            return []
        }

        // 3. JSON decodieren
        do {
            let decoded = try JSONDecoder().decode(
                StoryResponse.self,
                from: data
            )
            print("✅ StoryLoader: \(decoded.chapters.count) Kapitel geladen")

            for chapter in decoded.chapters {
                print(
                    "   📘 Kapitel: \(chapter.id) – \(chapter.title) (\(chapter.stages.count) Stages)"
                )
            }

            return decoded.chapters
        } catch {
            print("❌ StoryLoader ERROR: JSON Decode fehlgeschlagen")
            print("🔍 \(error)")
            return []
        }
    }
}
