//
//  EffectSystem.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftUI

@MainActor
final class EffectSystem {

    // Bindings zur Engine (UI-State)
    var enemyScale: CGFloat = 1
    var shakeOffset: CGFloat = 0
    var isFrozen: Bool = false

    // MARK: - Hit Effects

    func hitEnemy() {
        enemyScale = 1.15
        withAnimation(.spring(duration: 0.2)) {
            enemyScale = 1.0
        }
    }

    func hitStop(duration: Double = 0.05) {
        isFrozen = true
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isFrozen = false
        }
    }

    func shakeCamera(intensity: CGFloat = 10) {
        let frames: [CGFloat] = [intensity, -8, 6, -4, 2, 0]
        for (i, value) in frames.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                self.shakeOffset = value
            }
        }
    }

    func reset() {
        enemyScale = 1
        shakeOffset = 0
        isFrozen = false
    }
}
