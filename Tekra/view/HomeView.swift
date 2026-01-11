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

    var body: some View {

        ZStack {
            theme.chromeGradient()
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer()

                Image("tekra_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)

                Spacer()

                // MAIN MENU
                VStack(spacing: 20) {

                    NavigationLink(destination: GameView()) {
                        MenuButton(title: "Start Game", icon: "play")
                    }

                    NavigationLink(destination: EventView()) {
                        MenuButton(title: "Events", icon: "gamecontroller")
                    }

                    NavigationLink(destination: SettingsView()) {
                        MenuButton(title: "Settings", icon: "gear")
                    }

                    NavigationLink(destination: Text("Coming Soon")) {
                        MenuButton(title: "Coming Soon", icon: "hourglass")
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
