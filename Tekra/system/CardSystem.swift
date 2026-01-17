//
//  CardSystem.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

final class CardSystem {

    private var cooldowns: [String: Double] = [:]

    func isReady(card: Card, time: Double) -> Bool {
        time >= (cooldowns[card.id] ?? 0)
    }

    func play(card: Card, time: Double) {
        cooldowns[card.id] = time + card.cooldown
    }

    func progress(card: Card, time: Double) -> Double {
        guard let end = cooldowns[card.id] else { return 1 }
        return max(0, min(1, 1 - ((end - time) / card.cooldown)))
    }
}
