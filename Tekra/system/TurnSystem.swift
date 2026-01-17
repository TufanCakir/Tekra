//
//  TurnSystem.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

enum Turn {
    case player
    case enemy
    case locked
}

final class TurnSystem {

    private(set) var currentTurn: Turn = .player

    func startPlayerTurn() {
        currentTurn = .player
    }

    func startEnemyTurn() {
        currentTurn = .enemy
    }

    func lock() {
        currentTurn = .locked
    }

    func canPlayerAct() -> Bool {
        currentTurn == .player
    }
}
