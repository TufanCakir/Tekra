//
//  StoryChapterCard.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct StoryChapterCard: View {
    let chapter: StoryChapter
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {

                // MARK: - Background Image
                Image(chapter.background)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 170)
                    .clipped()
                    .overlay(
                        // Dunkler Verlauf für bessere Lesbarkeit
                        LinearGradient(
                            colors: [
                                .clear,
                                .black.opacity(0.6),
                                .black.opacity(0.9),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // MARK: - Content
                VStack(alignment: .leading, spacing: 8) {

                    Text("CHAPTER")
                        .font(.caption.bold())
                        .foregroundColor(.cyan)
                        .tracking(1.2)

                    Text(chapter.title.uppercased())
                        .font(
                            .system(
                                size: 24,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)

                    Text(chapter.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                .padding()
            }
            .background(Color.black)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.6),
                radius: 14,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }
}
