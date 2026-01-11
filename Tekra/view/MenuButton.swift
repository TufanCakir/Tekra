//
//  MenuButton.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct MenuButton: View {

    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let icon: String

    var theme: Theme { themeManager.current }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(hex: theme.text.primary))

            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(hex: theme.text.primary))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(chromePlate)
        .cornerRadius(theme.cornerRadius)
        .overlay(chromeEdge)
        .shadow(
            color: Color(hex: theme.metal.shadow).opacity(0.8),
            radius: 14,
            y: 8
        )
    }

    // MARK: - Chrome Layers

    var chromePlate: some View {
        ZStack {
            theme.chromeGradient()
            LinearGradient(
                colors: [
                    Color(hex: theme.metal.highlight),
                    Color(hex: theme.metal.edgeGlow),
                    Color(hex: theme.metal.shadow),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var chromeEdge: some View {
        RoundedRectangle(cornerRadius: theme.cornerRadius)
            .stroke(
                LinearGradient(
                    colors: [
                        Color(hex: theme.metal.highlight),
                        Color(hex: theme.metal.edgeGlow),
                        Color(hex: theme.metal.shadow),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
    }
}

#Preview {
    MenuButton(title: "testssdasydsadadadsad", icon: "")
        .environmentObject(
            ThemeManager(theme: ThemeLoader.load())
        )
}
