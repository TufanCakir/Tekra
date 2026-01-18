//
//  MusicManager.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import Observation

@Observable
class MusicManager {

    var enabled: Bool = true {
        didSet { updatePlayback() }
    }

    var volume: Float = 0.8 {
        didSet { updatePlayback() }
    }

    func apply(settings: MusicSettings) {
        enabled = settings.enabled
        volume = settings.masterVolume
    }

    private func updatePlayback() {
        if enabled {
            AudioEngine.shared.setVolume(volume)
            AudioEngine.shared.resume()
        } else {
            AudioEngine.shared.pause()
        }
    }
}
