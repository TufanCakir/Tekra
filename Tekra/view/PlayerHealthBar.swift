//
//  PlayerHealthBar.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import SwiftUI

struct PlayerHealthBar: View {
    let playerName: String
    let currentHP: CGFloat
    let maxHP: CGFloat

    private var ratio: CGFloat {
        max(0, min(1, currentHP / maxHP))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(playerName.uppercased())
                    .font(
                        .system(size: 10, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.cyan)

                Spacer()

                Text("\(Int(currentHP)) / \(Int(maxHP))")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }

            ZStack(alignment: .leading) {

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.6))

                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: ratio > 0.3
                                ? [.cyan, .green]
                                : [.red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(x: ratio, y: 1, anchor: .leading)
                    .animation(.easeOut(duration: 0.25), value: ratio)
            }
            .frame(height: 10)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
        )
    }
}
