//
//  RaidCard.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import SwiftUI

struct RaidCard: View {
    let boss: RaidBoss
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {

                // BACKGROUND
                Image(boss.raidBackground)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                    .overlay(backgroundGradient)

                VStack(alignment: .leading, spacing: 10) {

                    // RAID TAG
                    Text("RAID BOSS")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())

                    // NAME
                    Text(boss.name.uppercased())
                        .font(.system(size: 26, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // STATS
                    HStack(spacing: 14) {
                        statChip("HP", Int(boss.maxHP), .red)
                        statChip("ATK", Int(boss.attackPower), .orange)
                    }
                }
                .padding(16)
            }
            .cornerRadius(20)
            .overlay(borderOverlay)
            .shadow(color: .black.opacity(0.7), radius: 16, y: 10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func statChip(_ label: String, _ value: Int, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
            Text("\(value)")
        }
        .font(.system(size: 11, weight: .bold, design: .monospaced))
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.black.opacity(0.55)))
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.1),
                .black.opacity(0.9)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.red.opacity(0.4),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}
