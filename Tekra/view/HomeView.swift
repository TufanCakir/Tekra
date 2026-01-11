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
                VStack(spacing: 14) {

                    NavigationLink(destination: GameView()) {
                        MenuButton(title: "Start Game", icon: "play.fill")
                    }

                    NavigationLink(destination: EventView()) {
                        MenuButton(title: "Events", icon: "bolt.fill")
                    }

                    NavigationLink(destination: SettingsView()) {
                        MenuButton(title: "Settings", icon: "gearshape.fill")
                    }

                    NavigationLink(destination: Text("Coming Soon")) {
                        MenuButton(title: "Tekra Soon", icon: "hourglass")
                    }
                }

                Spacer()

                Text("v1.0")
                    .opacity(0.4)
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
