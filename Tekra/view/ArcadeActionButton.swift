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
    var isReady: Bool { engine.isCardReady(card) }
    var progress: CGFloat { engine.cooldownProgress(for: card) }

    var body: some View {
        // Erzwingt Redraw für Cooldown
        let _ = engine.lastUIUpdateTime
        let isReady = engine.isCardReady(card)
        let progress = engine.cooldownProgress(for: card)

        ZStack {

            // =========================
            // BASE CARD
            // =========================
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isReady
                                ? card.uiColor.opacity(0.9)
                                : Color.white.opacity(0.15),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: isReady
                        ? card.uiColor.opacity(0.5)
                        : .black.opacity(0.6),
                    radius: 12,
                    y: 6
                )

            // =========================
            // COOLDOWN OVERLAY
            // =========================
            if !isReady {
                RoundedRectangle(cornerRadius: 18)
                    .fill(card.uiColor.opacity(0.35))
                    .mask(
                        GeometryReader { geo in
                            VStack(spacing: 0) {
                                Rectangle()
                                    .frame(
                                        height: geo.size.height * (1 - progress)
                                    )
                                Spacer(minLength: 0)
                            }
                        }
                    )
                    .animation(.linear(duration: 0.08), value: progress)
            }

            // =========================
            // CONTENT
            // =========================
            VStack(spacing: 8) {

                Spacer(minLength: 6)

                Image(card.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .grayscale(isReady ? 0 : 1)
                    .opacity(isReady ? 1 : 0.65)
                    .scaleEffect(isReady ? 1.0 : 0.92)

                Text(card.title.uppercased())
                    .font(
                        .system(size: 11, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(isReady ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 6)

                Spacer(minLength: 6)
            }

            // =========================
            // DISABLED SCRIM
            // =========================
            if !isReady {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black.opacity(0.25))
            }
        }
        .frame(width: 92, height: 128)
        .scaleEffect(isReady ? 1.0 : 0.96)
        .animation(
            .spring(response: 0.25, dampingFraction: 0.75),
            value: isReady
        )
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture {
            guard isReady else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }
    }
}
