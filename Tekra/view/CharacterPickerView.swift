//
//  CharacterPickerView.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftUI

struct CharacterPickerView: View {
    @Environment(GameEngine.self) private var engine

    private let columns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18),
    ]

    var body: some View {
        let theme = engine.progress?.theme
        let accentColor = Color(hex: theme?.energy.ice.core ?? "#00FFFF")
        let level = engine.progress?.playerLevel ?? 1

        ScrollView {
            VStack(spacing: 20) {

                // 🧠 PLAYER LEVEL HEADER
                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .foregroundColor(accentColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("PLAYER LEVEL")
                            .font(.caption2)
                            .foregroundColor(.gray)

                        Text("LV. \(level)")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .black,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Optional XP Progress (future-proof)
                    Capsule()
                        .fill(accentColor.opacity(0.25))
                        .frame(width: 80, height: 6)
                        .overlay(
                            Capsule()
                                .fill(accentColor)
                                .frame(
                                    width: CGFloat(level % 10) / 10 * 80,
                                    height: 6
                                ),
                            alignment: .leading
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // 👇 CHARACTERS GRID
                LazyVGrid(columns: columns, spacing: 22) {
                    ForEach(FighterRegistry.playableCharacters) { hero in
                        characterCell(
                            hero: hero,
                            accentColor: accentColor
                        )
                    }
                }
                .padding(20)
            }
        }
    }

    @ViewBuilder
    private func characterCell(
        hero: Fighter,
        accentColor: Color
    ) -> some View {
        let isUnlocked = engine.progress?.isCharacterUnlocked(hero.id) ?? false

        Button {
            guard isUnlocked else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                engine.selectPlayer(hero)
            }
        } label: {
            // ⬅️ HIER dein bestehender VStack
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

#Preview {
    // Registry laden damit Daten da sind
    FighterRegistry.loadAll()

    return CharacterPickerView()
        .environment(GameEngine())
        .background(Color.black)
}
