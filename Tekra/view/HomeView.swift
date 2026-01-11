//
//  HomeView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var theme: Theme { themeManager.current }
    @State private var logoScale = 0.8
    @State private var logoOpacity = 0.0
    @State private var logoOffsetX: CGFloat = -400  // startet außerhalb links

    var body: some View {

        ZStack {
            theme.chromeGradient()
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

                    NavigationLink(destination: GameView()) {
                        MenuButton(title: "Start Game", icon: "bolt")
                    }

                    NavigationLink(destination: StoryView()) {
                        MenuButton(title: "Story", icon: "book")
                    }

                    NavigationLink(destination: ArcadeView()) {
                        MenuButton(
                            title: "Arcade",
                            icon: "arcade.stick.console"
                        )
                    }

                    NavigationLink(destination: EventView()) {
                        MenuButton(title: "Event", icon: "gamecontroller")
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
    NavigationStack {
        HomeView()
            .environmentObject(
                ThemeManager(theme: ThemeLoader.load())
            )
    }
}
