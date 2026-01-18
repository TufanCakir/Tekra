//
//  StoryRewardOverlayView.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import SwiftUI

struct StoryRewardOverlayView: View {
    let xp: Int
    let coins: Int
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            // 🌑 Dim Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 28) {

                // =====================
                // TITLE
                // =====================
                VStack(spacing: 6) {
                    Text("VICTORY")
                        .font(
                            .system(
                                size: 34,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)
                        .tracking(2)

                    Text("STAGE CLEARED")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // =====================
                // REWARDS
                // =====================
                HStack(spacing: 20) {
                    rewardCard(
                        icon: "bolt.fill",
                        title: "XP",
                        value: "+\(xp)",
                        color: .cyan
                    )

                    rewardCard(
                        icon: "creditcard.fill",
                        title: "COINS",
                        value: "+\(coins)",
                        color: .orange
                    )
                }

                // =====================
                // CONTINUE
                // =====================
                Button(action: onContinue) {
                    Text("CONTINUE")
                        .font(
                            .system(
                                size: 18,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .white.opacity(0.4), radius: 12)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.black.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(24)
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: xp)
    }

    // MARK: - Reward Card
    private func rewardCard(
        icon: String,
        title: String,
        value: String,
        color: Color
    ) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)

            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(0.4), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.35), radius: 10)
    }
}
