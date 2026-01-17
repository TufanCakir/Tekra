//
//  StoryView.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftData
import SwiftUI

struct StoryView: View {
    @Environment(GameEngine.self) private var engine
    @Environment(\.modelContext) private var modelContext

    // Holt Progress aus SwiftData (du hast PlayerProgress bereits als Model)
    @Query private var progresses: [PlayerProgress]

    @State private var chapters: [StoryChapter] = []
    @State private var selectedChapter: StoryChapter?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, Color.black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    storyHeader

                    if chapters.isEmpty {
                        emptyState
                    } else {
                        ForEach(chapters) { chapter in
                            StoryChapterCard(chapter: chapter) {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    selectedChapter = chapter
                                }
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // ✅ Story laden
            chapters = StoryLoader.load()

            // ✅ Progress sicherstellen + Engine mit DB verbinden
            let progress = ensureProgress()
            engine.setupDatabase(
                context: modelContext,
                playerProgress: progress
            )

            print(
                "✅ StoryView: Engine DB setup done. progress.unlocked=\(progress.unlockedCharacters)"
            )
        }
        .navigationDestination(item: $selectedChapter) { chapter in
            StoryChapterView(chapter: chapter)
        }
    }

    // MARK: - Progress Helper
    private func ensureProgress() -> PlayerProgress {
        if let existing = progresses.first {
            return existing
        }
        let created = PlayerProgress()  // falls dein init anders ist: entsprechend anpassen
        modelContext.insert(created)
        try? modelContext.save()
        return created
    }

    // MARK: - Header View
    private var storyHeader: some View {
        VStack(spacing: 10) {
            Text("STORY MODE")
                .font(.system(size: 30, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .italic()

            Text("Fight through chapters and shape your legend")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 24)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("No story chapters available")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.top, 40)
    }
}

#Preview {
    let engine = GameEngine()

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PlayerProgress.self,
        configurations: config
    )

    return NavigationStack {
        StoryView()
    }
    .environment(engine)  // ✅ Engine
    .modelContainer(container)  // ✅ SwiftData
}
