//
//  VictoryOverlayView.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct VictoryOverlayView: View {

    enum Style {
        case arcade
        case raid
        case event
    }

    let style: Style
    let event: GameEvent?
    let onExit: () -> Void

    var body: some View {
        ZStack {
            // Hintergrund mit leichtem Verlauf
            LinearGradient(
                colors: [.black.opacity(0.95), .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {

                // 🏆 TITLE
                VStack(spacing: 8) {
                    Text(title)
                        .font(
                            .system(
                                size: 34,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(accent)
                        .italic()
                        .shadow(color: accent.opacity(0.6), radius: 12)

                    Text("VICTORY")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(2)
                }

                // 🎁 REWARDS
                HStack(spacing: 24) {
                    rewardCard(
                        label: "XP",
                        value: "+\(xpReward)",
                        color: accent,
                        icon: "star.fill"
                    )

                    rewardCard(
                        label: "COINS",
                        value: "+\(coinReward)",
                        color: .orange,
                        icon: "bitcoinsign.circle.fill"
                    )
                }

                Spacer()

                // 🚪 EXIT BUTTON
                Button(action: onExit) {
                    Text(exitTitle)
                        .font(
                            .system(
                                size: 18,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: .green.opacity(0.5), radius: 10)
                }
            }
            .padding(30)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeOut(duration: 0.25), value: style)
    }

    // MARK: - Reward Card
    private func rewardCard(
        label: String,
        value: String,
        color: Color,
        icon: String
    ) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title.bold())
                .foregroundColor(color)

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.3), radius: 10)
    }

    // MARK: - Computed Values
    private var title: String {
        switch style {
        case .arcade: return "MISSION CLEAR"
        case .raid: return "RAID COMPLETE"
        case .event: return "EVENT CLEARED"
        }
    }

    private var exitTitle: String {
        switch style {
        case .arcade: return "CONTINUE"
        case .raid, .event: return "RETURN TO HUB"
        }
    }

    private var accent: Color {
        switch style {
        case .arcade: return .cyan
        case .raid: return .red
        case .event: return .purple
        }
    }

    private var xpReward: Int {
        if style == .event { return event?.rewardXP ?? 0 }
        if style == .raid { return 500 }
        return 75
    }

    private var coinReward: Int {
        if style == .event { return event?.rewardCoins ?? 0 }
        if style == .raid { return 0 }
        return 20
    }
}
