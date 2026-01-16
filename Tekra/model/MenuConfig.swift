//
//  MenuConfig.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import Foundation

struct MenuConfig: Codable {
    let menu: [MenuItem]
}

struct MenuItem: Codable, Identifiable {
    let id: String
    let title: String
    let icon: String
    let destination: Destination?

    enum Destination: String, Codable {
        case arcade
        case settings
        case event  // NEU hinzufügen
    }
}

enum MenuLoader {
    static func load() -> [MenuItem] {
        guard
            let url = Bundle.main.url(
                forResource: "menu",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let config = try? JSONDecoder().decode(MenuConfig.self, from: data)
        else {
            return []
        }
        return config.menu
    }
}
