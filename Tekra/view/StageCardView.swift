//
//  StageCardView.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct StageCardView: View {
    let stage: StoryStage
    let onSelect: (StoryDifficulty) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // =========================
            // HEADER
            // =========================
            HStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 6) {
                    Text(stage.title.uppercased())
                        .font(
                            .system(
                                size: 18,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)

                    Text("STAGE")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Optional: Boss Badge
                if stage.boss ?? false {
                    Text("BOSS")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // =========================
            // DIFFICULTIES
            // =========================
            HStack(spacing: 12) {
                ForEach(stage.difficulties, id: \.self) { difficulty in
                    DifficultyButton(difficulty: difficulty) {
                        onSelect(difficulty)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 10, y: 6)
    }
}
