//
//  SettingsView.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(GameEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    let availableThemes = [
        ("Silver Core", "theme"),
        ("Dark Matter", "theme_dark"),
        ("Neon Strike", "theme_neon"),
        ("Gold Edition", "theme_gold"),
    ]

    // Automatisches Auslesen der App-Version und Build-Nummer
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 1. DYNAMISCHER HINTERGRUND
                ThemeLoader.load(id: engine.activeThemeID).chromeGradient()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.6))

                ScrollView {
                    VStack(spacing: 35) {

                        // --- HEADER SECTION ---
                        VStack(spacing: 15) {
                            Image(systemName: "cpu.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.gray, .black],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .overlay(
                                            Circle().stroke(
                                                Color.white.opacity(0.2),
                                                lineWidth: 2
                                            )
                                        )
                                )
                                .shadow(color: .cyan.opacity(0.3), radius: 15)

                            VStack(spacing: 5) {
                                Text("TEKRA")
                                    .font(
                                        .system(
                                            size: 32,
                                            weight: .black,
                                            design: .monospaced
                                        )
                                    )
                                    .italic()
                                    .foregroundColor(.white)

                                Text("NEURAL COMBAT INTERFACE")
                                    .font(
                                        .system(
                                            size: 10,
                                            weight: .bold,
                                            design: .monospaced
                                        )
                                    )
                                    .foregroundColor(.cyan)
                                    .tracking(3)
                            }
                        }
                        .padding(.top, 20)

                        // --- THEME SELECTION SECTION ---
                        VStack(alignment: .leading, spacing: 15) {
                            sectionHeader(title: "HARDWARE APPEARANCE")

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(availableThemes, id: \.1) {
                                        themeName,
                                        themeID in
                                        ThemeCard(
                                            name: themeName,
                                            themeID: themeID,
                                            isSelected: engine.activeThemeID
                                                == themeID
                                        ) {
                                            engine.setTheme(themeID)
                                            UIImpactFeedbackGenerator(
                                                style: .medium
                                            ).impactOccurred()
                                        }
                                    }
                                }
                                .padding(.horizontal, 25)
                            }
                        }

                        // --- ABOUT / SYSTEM INFORMATION ---
                        VStack(alignment: .leading, spacing: 15) {
                            sectionHeader(title: "SYSTEM INFORMATION")

                            VStack(spacing: 1) {
                                settingsRow(
                                    title: "Kernel Status",
                                    value: "STABLE",
                                    color: .green
                                )
                                Divider().background(Color.white.opacity(0.1))
                                settingsRow(
                                    title: "Software Version",
                                    value: "v\(appVersion)"
                                )
                                Divider().background(Color.white.opacity(0.1))
                                settingsRow(
                                    title: "Build Revision",
                                    value: "REV-\(buildNumber)"
                                )

                                Divider().background(Color.white.opacity(0.1))

                                // Beschreibungstext
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("PROTOCOL DESCRIPTION")
                                        .font(
                                            .system(
                                                size: 10,
                                                weight: .bold,
                                                design: .monospaced
                                            )
                                        )
                                        .foregroundColor(.white.opacity(0.3))

                                    Text(
                                        "Tekra is a high-performance neural combat simulator. All hardware themes are cryptographically verified for optimal operator focus."
                                    )
                                    .font(
                                        .system(
                                            size: 12,
                                            weight: .medium,
                                            design: .monospaced
                                        )
                                    )
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineSpacing(4)
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12).stroke(
                                    Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                            )
                            .padding(.horizontal, 25)
                        }

                        // --- DISMISS BUTTON ---
                        Button(action: { dismiss() }) {
                            Text("CLOSE CONFIGURATION")
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .black,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(.black)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.cyan)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 40)
                    }
                }
            }
            .toolbar(.hidden)
        }
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .black, design: .monospaced))
            .foregroundColor(.cyan)
            .padding(.leading, 25)
    }

    private func settingsRow(
        title: String,
        value: String,
        color: Color = .white
    ) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}

// MARK: - ThemeCard Component
struct ThemeCard: View {
    let name: String
    let themeID: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.gray, .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 40, height: 40)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.cyan)
                    }
                }

                Text(name.uppercased())
                    .font(
                        .system(size: 10, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(isSelected ? .cyan : .white)
            }
            .frame(width: 110, height: 110)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        isSelected
                            ? Color.white.opacity(0.15)
                            : Color.black.opacity(0.3)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        isSelected ? Color.cyan : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
