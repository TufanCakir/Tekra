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
    @Environment(\.dismiss) private var dismiss

    @State private var logoScale = 0.8
    @State private var logoOpacity = 0.0
    @State private var logoOffsetX: CGFloat = -400  // startet außerhalb links

    var body: some View {

        ZStack {
            ThemeLoader.load(id: engine.activeThemeID).chromeGradient()
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer()

                Image("tekra_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(x: logoOffsetX)  // 👈 Position animieren
                    .onAppear {
                        withAnimation(
                            .interpolatingSpring(stiffness: 120, damping: 14)
                        ) {
                            logoScale = 1.0
                            logoOpacity = 1.0
                            logoOffsetX = 0
                        }
                    }

                Spacer()

                // MAIN MENU
                VStack(spacing: 20) {

                    NavigationLink(destination: ArcadeView()) {
                        MenuButton(title: "Start Game", icon: "bolt")
                    }

                    NavigationLink(destination: ArcadeView()) {
                        MenuButton(
                            title: "Arcade",
                            icon: "arcade.stick.console"
                        )
                    }

                    NavigationLink(destination: EventListView()) {
                        MenuButton(title: "Event", icon: "gamecontroller")
                    }

                    NavigationLink(destination: RaidView()) {
                        MenuButton(title: "Raid", icon: "dpad")
                    }

                    NavigationLink(destination: SettingsView()) {
                        MenuButton(title: "Settings", icon: "gear")
                    }
                }
            }
            .padding()
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
