//
//  RaidBoss.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

struct RaidBoss: Codable, Identifiable {
    let id: String
    let name: String
    let imageName: String
    let maxHP: Double
    let attackPower: Double
    let raidBackground: String

    // Konvertierung in das Standard Fighter-Modell
    func toFighter() -> Fighter {
        Fighter(
            id: id,
            name: name,
            imageName: imageName,
            maxHP: CGFloat(maxHP),
            attackPower: CGFloat(attackPower)
        )
    }
}
