//
//  HeaderView.swift
//  Tekra
//
//  Created by Tufan Cakir on 19.01.26.
//

import SwiftUI

struct HeaderView: View {

    @Environment(GameEngine.self) private var engine

    private var progress: PlayerProgress? {
        engine.progress
    }

    // MARK: - Derived Values

    private var level: Int {
        progress?.playerLevel ?? 1
    }

    private var xp: Int {
        progress?.currentXP ?? 0
    }

    private var xpForNextLevel: Int {
        progress?.xpForNextLevel ?? 100
    }

    private var xpProgress: Double {
        guard xpForNextLevel > 0 else { return 0 }
        return min(1, Double(xp) / Double(xpForNextLevel))
    }

    private var coins: Int {
        progress?.coins ?? 0
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 14) {

            // ───────────────
            // TOP ROW
            // ───────────────
            HStack {

                // ⭐ LEVEL BADGE
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.cyan)

                    Text("LV \(level)")
                        .font(
                            .system(
                                size: 14,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.cyan.opacity(0.15))
                )

                Spacer()

                // 🪙 COINS CHIP
                HStack(spacing: 6) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)

                    Text("\(coins)")
                        .font(
                            .system(
                                size: 14,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.15))
                )
            }

            // ───────────────
            // XP SECTION
            // ───────────────
            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text("ACCOUNT PROGRESS")
                        .font(.caption2.bold())
                        .foregroundColor(.gray)

                    Spacer()

                    Text("\(xp) / \(xpForNextLevel) XP")
                        .font(.caption2.monospacedDigit())
                        .foregroundColor(.gray)
                }

                // XP BAR
                GeometryReader { proxy in
                    let width = proxy.size.width

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 10)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(8, width * xpProgress),
                                height: 10
                            )
                            .shadow(color: .cyan.opacity(0.6), radius: 6)
                            .animation(
                                .easeOut(duration: 0.3),
                                value: xpProgress
                            )
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

#Preview {
    let engine = GameEngine()
    return HeaderView()
        .environment(engine)
        .background(Color.black)
}
