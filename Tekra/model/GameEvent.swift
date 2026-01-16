//
//  GameEvent.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//
import Foundation

struct GameEvent: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let background: String
    let enemies: [String]
    let rewards: [EventReward]
    let requiredLevel: Int
    let active: Bool

    // HELPER: Extrahiert XP aus der rewards-Liste
    var rewardXP: Int {
        rewards.first(where: { $0.type == .xp })?.amount ?? 0
    }

    // HELPER: Falls du Coins hinzufügen möchtest (ergänze .coins im enum unten)
    var rewardCoins: Int {
        rewards.first(where: { $0.type == .coins })?.amount ?? 0
    }
}

struct EventReward: Codable {
    let type: RewardType
    let amount: Int?
    let idRef: String?

    enum RewardType: String, Codable {
        case xp, card, theme, coins  // 'coins' hinzugefügt für das Layout
    }
}

struct EventResponse: Codable {
    let events: [GameEvent]
}
