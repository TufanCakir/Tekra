//
//  StoryResponse.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import Foundation
import CoreGraphics

struct StoryResponse: Codable {
    let chapters: [StoryChapter]
}

struct StoryChapter: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let background: String
    let stages: [StoryStage]
}

struct StoryStage: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let enemy: String  // STORY enemy id

    let baseHP: CGFloat
    let baseAttack: CGFloat

    let boss: Bool?
    let difficulties: [StoryDifficulty]
    let unlocksCharacter: String?
    let rewards: StoryRewards   // ⬅️ NEU
}

struct StoryRewards: Codable, Hashable {
    let xp: Int
    let coins: Int
}

struct StageSelection: Identifiable, Hashable {
    let id = UUID()
    let stage: StoryStage
    let difficulty: StoryDifficulty
}

struct StoryEnemy {
    let id: String  // story_frozen_king
    let name: String
    let imageName: String
    let baseHP: Int
    let baseAttack: Int
}

extension StoryStage {

    func makeEnemy(difficulty: StoryDifficulty) -> Fighter {
        Fighter(
            id: enemy,  // 👈 STABIL
            name: title,
            imageName: enemy,
            maxHP: baseHP * difficulty.hpMultiplier,
            attackPower: baseAttack * difficulty.damageMultiplier,
            availablePoses: boss == true
                ? ["idle", "punch", "kick", "special"]
                : ["idle", "punch", "kick"],
            cardOwners: [id, "boss", "generic"]  // ✅ FIX
        )
    }
}
