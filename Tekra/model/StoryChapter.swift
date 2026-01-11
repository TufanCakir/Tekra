//
//  StoryChapter.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import Foundation

struct StoryChapter: Identifiable, Codable {
    let id: Int
    let title: String
    let text: String
    let enemies: [Fighter]
}



struct StoryLoader {
    static func load() -> [StoryChapter] {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let chapters = try? JSONDecoder().decode([StoryChapter].self, from: data) else {
            return []
        }
        return chapters
    }
}
