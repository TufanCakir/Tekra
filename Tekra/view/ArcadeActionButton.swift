//
//  ArcadeActionButton.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import SwiftUI

struct ArcadeCardButton: View {
    let card: Card
    @Environment(GameEngine.self) private var engine
    let action: () -> Void

    var body: some View {
        // Der Zugriff auf lastUIUpdateTime zwingt SwiftUI zum Redraw bei jedem Frame
        let _ = engine.lastUIUpdateTime
        let isReady = engine.isCardReady(card)
        let progress = engine.cooldownProgress(for: card)

        ZStack {
            // 1. Hintergrund & Schatten-Glow wenn bereit
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .shadow(
                    color: isReady ? card.uiColor.opacity(0.5) : .clear,
                    radius: 10
                )

            // 2. Cooldown-Füllung (von unten nach oben)
            if !isReady {
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.uiColor.opacity(0.3))
                    .mask(
                        GeometryReader { geo in
                            VStack {
                                Spacer(minLength: 0)
                                Rectangle()
                                    .frame(height: geo.size.height * progress)
                            }
                        }
                    )
                    // Sanfter Übergang der Farbe
                    .animation(.linear(duration: 0.1), value: progress)
            }

            // 3. Rand-Leuchten
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isReady ? card.uiColor : Color.gray.opacity(0.3),
                    lineWidth: 2
                )
                .overlay(
                    // Ein kleiner Blitz-Effekt wenn 100% erreicht sind
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.white.opacity(isReady ? 0.3 : 0),
                            lineWidth: 4
                        )
                        .blur(radius: 2)
                )

            // 4. Inhalt
            VStack(spacing: 8) {
                Image(card.actionImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45, height: 45)
                    .grayscale(isReady ? 0 : 1.0)  // Grau wenn im Cooldown
                    .brightness(isReady ? 0 : -0.2)
                    .scaleEffect(isReady ? 1.0 : 0.9)

                Text(card.title)
                    .font(
                        .system(size: 10, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(isReady ? .white : .gray)
                    .multilineTextAlignment(.center)
            }
            .padding(5)
        }
        .frame(width: 85, height: 115)
        // Haptisches Feedback & Skalierung beim Drücken
        .scaleEffect(isReady ? 1.0 : 0.95)
        .onTapGesture {
            if isReady {
                let haptic = UIImpactFeedbackGenerator(style: .medium)
                haptic.impactOccurred()
                action()
            }
        }
    }
}

#Preview {
    let engine = GameEngine()
    // Dummy Karten für die Vorschau
    let dummyPunch = Card(
        id: "1",
        title: "PUNCH",
        actionImage: "sly_punch",
        damage: 10,
        type: .punch,
        colorHex: "#3498db",
        cooldown: 2.0
    )
    let dummyKick = Card(
        id: "2",
        title: "KICK",
        actionImage: "sly_kick",
        damage: 20,
        type: .kick,
        colorHex: "#e74c3c",
        cooldown: 3.0
    )

    return HStack {
        ArcadeCardButton(card: dummyPunch) {
            print("Punch!")
        }
        ArcadeCardButton(card: dummyKick) {
            print("Kick!")
        }
    }
    .environment(engine)
}
