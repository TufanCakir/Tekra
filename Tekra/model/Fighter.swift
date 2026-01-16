//
//  Fighter.swift
//  Tekra
//
//  Created by Tufan Cakir on 10.01.26.
//

import Foundation

struct Fighter: Identifiable, Codable {
    let id: String  // 👈 STABIL (für JSON, Events, Saves)
    var name: String
    var imageName: String
    var maxHP: CGFloat
    var attackPower: CGFloat
}
