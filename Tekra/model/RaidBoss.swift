//
//  RaidBoss.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import CoreGraphics
import Foundation

struct RaidBoss: Identifiable, Hashable, Decodable {
    let id: String
    let name: String
    let imageName: String
    let maxHP: Double
    let attackPower: Double
    let raidBackground: String
    let availablePoses: Set<String>

    enum CodingKeys: String, CodingKey {
        case id, name, imageName, maxHP, attackPower, raidBackground,
            availablePoses
    }

    init(
        id: String,
        name: String,
        imageName: String,
        maxHP: Double,
        attackPower: Double,
        raidBackground: String,
        availablePoses: Set<String> = ["idle", "punch", "kick", "special"]
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.maxHP = maxHP
        self.attackPower = attackPower
        self.raidBackground = raidBackground
        self.availablePoses = availablePoses
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        imageName = try c.decode(String.self, forKey: .imageName)
        maxHP = try c.decode(Double.self, forKey: .maxHP)
        attackPower = try c.decode(Double.self, forKey: .attackPower)
        raidBackground = try c.decode(String.self, forKey: .raidBackground)

        // 🔥 DAS ist der entscheidende Teil
        availablePoses =
            try c.decodeIfPresent(Set<String>.self, forKey: .availablePoses)
            ?? ["idle", "punch", "kick", "special"]
    }
}

extension RaidBoss {
    func makeFighter(phaseMultiplier: CGFloat = 1.0) -> Fighter {
        Fighter(
            id: id,
            name: name,
            imageName: imageName,
            maxHP: CGFloat(maxHP) * phaseMultiplier,
            attackPower: CGFloat(attackPower) * phaseMultiplier,
            availablePoses: availablePoses,
            cardOwners: [id, "boss", "generic"]  // ✅ FIX
        )
    }
}
