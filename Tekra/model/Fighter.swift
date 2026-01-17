//
//  Fighter.swift
//  Tekra
//
//  Created by Tufan Cakir on 10.01.26.
//

import Foundation
import SwiftData

struct Fighter: Identifiable, Codable {
    let id: String
    let name: String
    let imageName: String
    let maxHP: CGFloat
    let attackPower: CGFloat
    let availablePoses: Set<String>
    let cardOwners: [String]

    enum CodingKeys: String, CodingKey {
        case id, name, imageName, maxHP, attackPower, availablePoses
        case owner  // 👈 aus JSON
        case cardOwners  // 👈 optional (future)
    }

    init(
        id: String,
        name: String,
        imageName: String,
        maxHP: CGFloat,
        attackPower: CGFloat,
        availablePoses: Set<String>,
        cardOwners: [String]
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.maxHP = maxHP
        self.attackPower = attackPower
        self.availablePoses = availablePoses
        self.cardOwners = cardOwners
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        imageName = try c.decode(String.self, forKey: .imageName)
        maxHP = try c.decode(CGFloat.self, forKey: .maxHP)
        attackPower = try c.decode(CGFloat.self, forKey: .attackPower)
        availablePoses =
            try c.decodeIfPresent(Set<String>.self, forKey: .availablePoses)
            ?? ["idle"]

        // 🔥 MAGIE HIER
        if let owners = try c.decodeIfPresent(
            [String].self,
            forKey: .cardOwners
        ) {
            cardOwners = owners
        } else if let singles = try c.decodeIfPresent(
            [String].self,
            forKey: .owner
        ) {
            cardOwners = singles
        } else {
            cardOwners = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(imageName, forKey: .imageName)
        try c.encode(maxHP, forKey: .maxHP)
        try c.encode(attackPower, forKey: .attackPower)
        try c.encode(availablePoses, forKey: .availablePoses)
        // ✅ Zukunftssicher: immer als Array speichern
        try c.encode(cardOwners, forKey: .cardOwners)
    }
}
