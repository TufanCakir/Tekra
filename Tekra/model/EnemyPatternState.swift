//
//  EnemyPatternState.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import Foundation

final class EnemyPatternState {

    private let pattern: [EnemyPatternStep]
    private var index: Int = 0

    init(pattern: [EnemyPatternStep]) {
        self.pattern = pattern
    }

    func next() -> EnemyPatternStep {
        let step = pattern[index]
        index = (index + 1) % pattern.count
        return step
    }
}
