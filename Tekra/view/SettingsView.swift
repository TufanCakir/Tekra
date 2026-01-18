//
//  SettingsView.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import SwiftData
import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(GameEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss
    @Environment(MusicManager.self) private var musicEnv
    @Bindable private var music: MusicManager

    init() {
        // Bridge optional environment object to a non-optional bindable source
        _music = Bindable(
            wrappedValue: (EnvironmentValues()[MusicManager.self]
                ?? MusicManager())
        )
    }

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
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 35) {
                        audioSection
                        aboutSection
                        closeButton
                    }
                }
            }
            .toolbar(.hidden)
        }
    }

    // MARK: - Audio
    private var audioSection: some View {
        systemSection(title: "AUDIO SYSTEM") {
            VStack(spacing: 20) {
                Toggle(isOn: $music.enabled) {
                    Label(
                        music.enabled
                            ? "BACKGROUND MUSIC: ON" : "BACKGROUND MUSIC: OFF",
                        systemImage: music.enabled
                            ? "speaker.wave.2.fill"
                            : "speaker.slash.fill"
                    )
                }
                .tint(.cyan)

                VStack(alignment: .leading, spacing: 8) {
                    Text("MASTER VOLUME")

                    Slider(value: $music.volume, in: 0...1)
                        .tint(.cyan)

                    Text("\(Int(music.volume * 100)) %")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .disabled(!music.enabled)
                .opacity(music.enabled ? 1 : 0.4)
            }
        }
    }

    // MARK: - About
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            systemSection(title: "ABOUT") {
                VStack(spacing: 0) {
                    settingsRow(
                        title: "Kernel Status",
                        value: "STABLE",
                        color: .green
                    )
                    dividerLine
                    settingsRow(title: "Version", value: "v\(appVersion)")
                    dividerLine
                    settingsRow(title: "Build", value: "REV-\(buildNumber)")
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(
                    """
                    Tekra is a high-performance neural combat simulator.
                    Audio and system modules are dynamically optimized
                    for maximum combat focus.
                    """
                )
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Close Button
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Text("CLOSE")
                .font(.system(size: 14, weight: .black, design: .monospaced))
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
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
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
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 20)
    }

    @ViewBuilder
    private func systemSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08))
            )
            .padding(.horizontal, 16)
        }
    }
}
