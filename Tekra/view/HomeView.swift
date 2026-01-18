//
//  HomeView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(GameEngine.self) private var engine

    @State private var logoScale = 0.8
    @State private var logoOpacity = 0.0
    @State private var logoOffsetX: CGFloat = -300

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeLoader.load(id: engine.activeThemeID)
                    .chromeGradient()
                    .ignoresSafeArea()

                VStack {
                    HeaderView()

                    Spacer()

                    Image("tekra_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 380)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .offset(x: logoOffsetX)
                        .onAppear {
                            withAnimation(
                                .interpolatingSpring(
                                    stiffness: 120,
                                    damping: 14
                                )
                            ) {
                                logoScale = 1
                                logoOpacity = 1
                                logoOffsetX = 0
                            }
                        }

                    Spacer()

                    VStack(spacing: 18) {

                        NavigationLink(destination: StoryView()) {
                            MenuButton(title: "Story", icon: "book")
                        }

                        NavigationLink(destination: ArcadeView()) {
                            MenuButton(title: "Arcade", icon: "arcade.stick")
                        }

                        NavigationLink(destination: EventListView()) {
                            MenuButton(title: "Event", icon: "gamecontroller")
                        }

                        NavigationLink(destination: RaidListView()) {
                            MenuButton(title: "Raid", icon: "dpad")
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

#Preview {
    // VOR dem Preview die Daten laden!
    FighterRegistry.loadAll()

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PlayerProgress.self,
        configurations: config
    )
    let engine = GameEngine()

    return HomeView()
        .environment(engine)
        .modelContainer(container)
}
