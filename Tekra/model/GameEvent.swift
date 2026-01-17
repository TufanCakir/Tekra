//
//  GameEvent.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//
import Foundation

struct GameEvent: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let background: String
    let enemies: [String]
    let rewards: [EventReward]
    let requiredLevel: Int
    let active: Bool

    // MARK: - Rewards Helper

    var rewardXP: Int {
        rewards.first { $0.type == .xp }?.amount ?? 0
    }

    var rewardCoins: Int {
        rewards.first { $0.type == .coins }?.amount ?? 0
    }
}

struct EventReward: Codable, Hashable {
    let type: RewardType
    let amount: Int?
    let idRef: String?

    enum RewardType: String, Codable, Hashable {
        case xp
        case card
        case theme
        case coins
    }
}

struct EventResponse: Codable {
    let events: [GameEvent]
}
