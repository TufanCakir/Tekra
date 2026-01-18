//
//  TekraApp.swift
//  Tekra
//
//  Created by Tufan Cakir on 10.01.26.
//

import SwiftData
import SwiftUI

@main
struct TekraApp: App {

    @State private var engine = GameEngine()
    @State private var musicManager = MusicManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(engine)
                .environment(musicManager)
                .modelContainer(for: PlayerProgress.self)
                .onAppear {
                    // 🎵 START GLOBAL MUSIC ONCE
                    AudioEngine.shared.playMusic(named: "rise_of_legends")

                    // 🔊 Apply initial volume & enabled state
                    AudioEngine.shared.setVolume(musicManager.volume)
                    if !musicManager.enabled {
                        AudioEngine.shared.pause()
                    }
                }
        }
    }
}
