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
                            systemSection(title: "HARDWARE APPEARANCE") {
                                ScrollView(.horizontal, showsIndicators: false)
                                {
                                    HStack(spacing: 18) {
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
                                    .padding(.horizontal, 6)
                                }
                            }

                            // --- ABOUT / SYSTEM INFORMATION ---
                            VStack(alignment: .leading, spacing: 15) {
                                systemSection(title: "SYSTEM INFORMATION") {
                                    VStack(spacing: 0) {
                                        settingsRow(
                                            title: "Kernel Status",
                                            value: "STABLE",
                                            color: .green
                                        )
                                        dividerLine
                                        settingsRow(
                                            title: "Software Version",
                                            value: "v\(appVersion)"
                                        )
                                        dividerLine
                                        settingsRow(
                                            title: "Build Revision",
                                            value: "REV-\(buildNumber)"
                                        )
                                    }
                                }

                                // Beschreibungstext
                                VStack(alignment: .leading, spacing: 10) {
                                    DisclosureGroup {
                                        Text(
                                            """
                                            Tekra is a high-performance neural combat simulator.
                                            All hardware themes are cryptographically verified
                                            for optimal operator focus.
                                            """
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
                                    } label: {
                                        Text("PROTOCOL DESCRIPTION")
                                            .font(
                                                .system(
                                                    size: 11,
                                                    weight: .black,
                                                    design: .monospaced
                                                )
                                            )
                                            .foregroundColor(
                                                .white.opacity(0.4)
                                            )
                                    }

                                    // --- DISMISS BUTTON ---
                                    Button {
                                        dismiss()
                                    } label: {
                                        Text("EXIT CONFIGURATION")
                                            .font(
                                                .system(
                                                    size: 14,
                                                    weight: .black,
                                                    design: .monospaced
                                                )
                                            )
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(
                                                LinearGradient(
                                                    colors: [.cyan, .blue],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .cornerRadius(12)
                                            .shadow(
                                                color: .cyan.opacity(0.4),
                                                radius: 10
                                            )
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 40)
                                }
                            }
                        }
                    }
                }
                .toolbar(.hidden)
            }
        }
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

private var dividerLine: some View {
    Divider().background(Color.white.opacity(0.08))
}

private func systemSection<Content: View>(
    title: String,
    content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: 16) {
        Text(title)
            .font(.system(size: 12, weight: .black, design: .monospaced))
            .foregroundColor(.cyan)
            .tracking(1.5)

        content()
    }
    .padding(20)
    .background(Color.black.opacity(0.45))
    .cornerRadius(16)
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.white.opacity(0.08), lineWidth: 1)
    )
    .padding(.horizontal, 24)
}
