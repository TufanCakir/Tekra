//
//  BossHealthBar.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct BossHealthBar: View {
    let currentHP: CGFloat
    let maxHP: CGFloat

    private var ratio: CGFloat {
        max(0, min(1, currentHP / maxHP))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // HEADER
            HStack {
                Text("BOSS")
                    .font(
                        .system(size: 12, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.red)

                Spacer()

                Text("\(Int(currentHP)) / \(Int(maxHP))")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }

            // HEALTH BAR
            ZStack(alignment: .leading) {

                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                // HP Fill
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: ratio > 0.3
                                ? [.red, .orange]
                                : [.red, .red.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(x: ratio, y: 1, anchor: .leading)
                    .animation(.easeOut(duration: 0.25), value: ratio)

                // Critical Glow
                if ratio < 0.25 {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(0.8), lineWidth: 2)
                        .blur(radius: 4)
                }
            }
            .frame(height: 16)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .red.opacity(0.35), radius: 12)
    }
}
