//
//  MusicSettings.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import Foundation

struct MusicSettings: Codable {
    var enabled: Bool
    var masterVolume: Float
}

struct GameSong: Codable, Identifiable {
    let id: String
    let title: String
    let file: String
    let type: String
    let loop: Bool
    let defaultVolume: Float
}

struct SongLibrary: Codable {
    let musicSettings: MusicSettings
    let songs: [GameSong]
}
