//
//  DifficultyButton.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct DifficultyButton: View {
    let difficulty: StoryDifficulty
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            Text(difficulty.title.uppercased())
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(difficulty.color)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        Capsule()
                            .fill(Color.black.opacity(0.4))

                        Capsule()
                            .fill(difficulty.color.opacity(0.18))
                    }
                )
                .overlay(
                    Capsule()
                        .stroke(
                            difficulty.color.opacity(0.6),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: difficulty.color.opacity(0.45),
                    radius: isPressed ? 4 : 10
                )
                .scaleEffect(isPressed ? 0.94 : 1.0)
                .animation(
                    .spring(response: 0.25, dampingFraction: 0.65),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
