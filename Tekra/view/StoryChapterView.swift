//
//  StoryChapterView.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct StoryChapterView: View {
    let chapter: StoryChapter
    @State private var selection: StageSelection?

    var body: some View {
        ZStack {
            // MARK: - Background
            LinearGradient(
                colors: [.black, Color.black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    // MARK: - Chapter Header
                    chapterHeader

                    // MARK: - Stages
                    ForEach(chapter.stages) { stage in
                        StageCardView(stage: stage) { difficulty in
                            withAnimation(.easeOut(duration: 0.2)) {
                                selection = StageSelection(
                                    stage: stage,
                                    difficulty: difficulty
                                )
                            }
                        }
                        .transition(
                            .opacity.combined(with: .move(edge: .bottom))
                        )
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selection) { sel in
            StoryBattleView(
                stage: sel.stage,
                difficulty: sel.difficulty
            )
        }
    }

    // MARK: - Header
    private var chapterHeader: some View {
        ZStack(alignment: .bottomLeading) {

            Image(chapter.background)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("CHAPTER")
                    .font(.caption.bold())
                    .foregroundColor(.cyan)

                Text(chapter.title.uppercased())
                    .font(
                        .system(size: 30, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.white)

                Text(chapter.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.6), radius: 14)
        .padding(.top, 10)
    }
}
