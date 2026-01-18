//
//  AudioEngine.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import AVFoundation

@MainActor
final class AudioEngine {

    static let shared = AudioEngine()

    private var player: AVAudioPlayer?

    private init() {}

    // MARK: - Load & Play
    func playMusic(named name: String, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3")
        else {
            print("❌ AudioEngine: File not found:", name)
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = loop ? -1 : 0
            player?.volume = 1.0
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("❌ AudioEngine: Failed to play:", error)
        }
    }

    // MARK: - Controls
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }

    func pause() {
        player?.pause()
    }

    func resume() {
        player?.play()
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
