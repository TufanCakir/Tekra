//
//  EventCard.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftUI

struct EventCard: View {
    let event: GameEvent
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            ZStack(alignment: .bottomLeading) {

                // MARK: - Background Image
                Image(event.background)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
                    .overlay(backgroundGradient)

                // MARK: - Content
                VStack(alignment: .leading, spacing: 8) {

                    // EVENT TAG
                    Text("WORLD EVENT")
                        .font(.caption.bold())
                        .foregroundColor(.purple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.45))
                        .clipShape(Capsule())

                    // TITLE
                    Text(event.title.uppercased())
                        .font(
                            .system(
                                size: 24,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.yellow)
                        .lineLimit(1)

                    // DESCRIPTION
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)

                    // REWARDS
                    HStack(spacing: 12) {
                        rewardChip(
                            icon: "sparkles",
                            value: "+\(event.rewardXP) XP",
                            color: .purple
                        )

                        if event.rewardCoins > 0 {
                            rewardChip(
                                icon: "bitcoinsign.circle.fill",
                                value: "+\(event.rewardCoins)",
                                color: .orange
                            )
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(16)
            }
            .background(Color.black)
            .cornerRadius(18)
            .overlay(borderOverlay)
            .shadow(color: .black.opacity(0.65), radius: 14, y: 8)
            .skewed(degrees: -4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.05),
                Color.black.opacity(0.9),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Border
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 18)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.35),
                        Color.white.opacity(0.08),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    // MARK: - Reward Chip
    private func rewardChip(
        icon: String,
        value: String,
        color: Color
    ) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.5))
        )
    }
}
