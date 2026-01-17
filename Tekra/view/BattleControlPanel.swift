//
//  BattleControlPanel.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct BattleControlPanel: View {
    let color: Color
    let cards: [Card]
    let onPlay: (Card) -> Void

    var body: some View {
        VStack(spacing: 10) {

            // TOP ACCENT LINE
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.0),
                            color.opacity(0.6),
                            color.opacity(0.0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)

            // CARD BAR
            HStack(spacing: 16) {
                ForEach(cards) { card in
                    ArcadeCardButton(card: card) {
                        onPlay(card)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .background(
            ZStack {
                // Base Panel
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.75))

                // Subtle Gradient
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.05),
                                Color.black.opacity(0.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.35), radius: 14, y: -6)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}
