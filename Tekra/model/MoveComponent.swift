//
//  MoveComponent.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import GameplayKit
import SpriteKit

class MoveComponent: GKComponent {
    var position: CGPoint = .zero
    var velocity: CGFloat = 0

    // Konfiguration für das "Arcade-Gefühl"
    let maxSpeed: CGFloat = 600  // Erhöht für wuchtigere Dashes
    let acceleration: CGFloat = 3000  // Schnellerer Antritt
    let friction: CGFloat = 1500  // Sauberes Abstoppen

    // Dynamische Spielfeldbegrenzung
    // minX ist der Startpunkt, maxX ist kurz vor dem Gegner
    var minX: CGFloat = -200
    var maxX: CGFloat = 200

    override func update(deltaTime seconds: TimeInterval) {
        let dt = CGFloat(seconds)

        // 1. Reibung anwenden (bevor die Position berechnet wird)
        applyFriction(dt: dt)

        // 2. Neue Position berechnen
        let nextX = position.x + (velocity * dt)

        // 3. STRENGES CLAMPING (Der "Sicherheits-Käfig")
        // Wir prüfen, ob die nächste Position außerhalb der Grenzen liegen würde
        if nextX < minX {
            position.x = minX
            velocity = 0  // Sofortiger Stopp an der Wand
        } else if nextX > maxX {
            position.x = maxX
            velocity = 0  // Sofortiger Stopp am Gegner
        } else {
            position.x = nextX
        }
    }

    // Wird von der Engine aufgerufen (z.B. durch Karten oder Stick)
    func applyInput(direction: CGFloat, dt: CGFloat) {
        if direction != 0 {
            velocity += direction * acceleration * dt

            // Speed Limit einhalten
            if abs(velocity) > maxSpeed {
                velocity = (velocity > 0 ? maxSpeed : -maxSpeed)
            }
        }
    }

    private func applyFriction(dt: CGFloat) {
        // Nur stoppen, wenn keine aktive Kraft wirkt oder wir bremsen wollen
        if abs(velocity) > 0 {
            let reduction = friction * dt
            if velocity > 0 {
                velocity = max(0, velocity - reduction)
            } else {
                velocity = min(0, velocity + reduction)
            }
        }
    }
}
