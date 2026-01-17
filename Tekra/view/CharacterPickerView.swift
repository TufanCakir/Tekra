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

        ScrollView {
            LazyVGrid(columns: columns, spacing: 22) {

                ForEach(FighterRegistry.playableCharacters) { hero in
                    let isUnlocked =
                        engine.progress?.isCharacterUnlocked(hero.id) ?? false
                    let isSelected =
                        engine.currentPlayer?.id == hero.id

                    Button {
                        guard isUnlocked else { return }
                        withAnimation(
                            .spring(response: 0.35, dampingFraction: 0.75)
                        ) {
                            engine.selectPlayer(hero)
                        }
                    } label: {
                        VStack(spacing: 14) {

                            // MARK: - Portrait
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.4))
                                    .frame(width: 96, height: 96)

                                Image(hero.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 72, height: 72)
                                    .opacity(isUnlocked ? 1 : 0.25)

                                if isSelected {
                                    Circle()
                                        .stroke(accentColor, lineWidth: 3)
                                        .frame(width: 96, height: 96)
                                        .shadow(
                                            color: accentColor.opacity(0.8),
                                            radius: 12
                                        )
                                }

                                if !isUnlocked {
                                    VStack(spacing: 6) {
                                        Image(systemName: "lock.fill")
                                        Text("LOCKED")
                                            .font(.caption.bold())
                                    }
                                    .foregroundColor(.gray)
                                }
                            }

                            // MARK: - Name
                            Text(hero.name.uppercased())
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .black,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(
                                    isUnlocked ? .white : .gray
                                )
                                .lineLimit(1)

                            // MARK: - Stats
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                Text("\(Int(hero.attackPower)) ATK")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(
                                isUnlocked ? accentColor : .gray
                            )
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(
                                        isUnlocked
                                            ? accentColor.opacity(0.18)
                                            : Color.white.opacity(0.06)
                                    )
                            )
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    isSelected
                                        ? Color.white.opacity(0.08)
                                        : Color.black.opacity(0.3)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isSelected
                                        ? accentColor.opacity(0.6)
                                        : Color.white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                        .scaleEffect(isSelected ? 1.03 : 1.0)
                        .opacity(isUnlocked ? 1 : 0.45)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isUnlocked)
                }
            }
            .padding(20)
        }
    }
}

#Preview {
    // Registry laden damit Daten da sind
    FighterRegistry.loadAll()

    return CharacterPickerView()
        .environment(GameEngine())
        .background(Color.black)
}
