//
//  SettingsView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var theme: Theme { themeManager.current }

    @State private var language = "English"
    @State private var soundEnabled = true
    @State private var volume: Double = 0.6

    let languages = ["English", "Deutsch", "Español", "日本語"]

    var body: some View {
        ZStack {
            theme.chromeGradient()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    sectionTitle("LANGUAGE")
                    chromeCard {
                        Picker("Language", selection: $language) {
                            ForEach(languages, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.navigationLink)
                    }

                    sectionTitle("AUDIO")
                    chromeCard {
                        Toggle("Sound Enabled", isOn: $soundEnabled)
                        VStack(alignment: .leading) {
                            Text("Volume")
                            Slider(value: $volume)
                        }
                    }

                    sectionTitle("ACCOUNT")
                    chromeCard {
                        chromeRow("Connect with Apple")
                        chromeRow("Connect with Google")
                        chromeRow("Connect with Facebook")
                    }

                    sectionTitle("ABOUT")
                    chromeCard {
                        chromeRow("Version \(appVersion)")
                        chromeRow("Build \(appBuild)")
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - UI Helpers

    func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .black))
            .foregroundStyle(Color(hex: theme.text.primary))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func chromeCard<Content: View>(@ViewBuilder content: () -> Content)
        -> some View
    {
        VStack(alignment: .leading, spacing: 16) {
            content()
        }
        .padding()
        .background(theme.chromeGradient())
        .cornerRadius(theme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(Color(hex: theme.metal.edgeGlow), lineWidth: 2)
        )
        .shadow(color: Color(hex: theme.metal.shadow), radius: 12, y: 6)
    }

    func chromeRow(_ text: String) -> some View {
        HStack {
            Text(text)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundColor(Color(hex: theme.text.primary))
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "?"
    }

    var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(
                ThemeManager(theme: ThemeLoader.load())
            )
    }
}
