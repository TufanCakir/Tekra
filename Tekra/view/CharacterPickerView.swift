//
//  CharacterPickerView.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftUI

struct CharacterPickerView: View {
    @Environment(GameEngine.self) private var engine

    // Grid-Layout: 2 Spalten, die sich flexibel anpassen
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
    ]

    var body: some View {
        let theme = engine.progress?.theme
        let accentColor = Color(hex: theme?.energy.ice.core ?? "#00FFFF")

        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(FighterRegistry.playableCharacters) { hero in
                    let isSelected = engine.currentPlayer?.id == hero.id

                    Button(action: {
                        withAnimation(
                            .spring(response: 0.3, dampingFraction: 0.7)
                        ) {
                            engine.selectPlayer(hero)
                        }
                    }) {
                        VStack(spacing: 12) {
                            // RUNDES ICON MIT GLOW
                            ZStack {
                                // Äußerer Ring (nur wenn ausgewählt)
                                Circle()
                                    .stroke(
                                        isSelected
                                            ? accentColor
                                            : Color.white.opacity(0.1),
                                        lineWidth: 3
                                    )
                                    .frame(width: 110, height: 110)

                                // Hintergrund Glow
                                if isSelected {
                                    Circle()
                                        .fill(accentColor.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                        .blur(radius: 15)
                                }

                                // Das eigentliche Bild (Beschnitten auf Kreis)
                                Image(hero.imageName)
                                    .resizable()
                                    .scaledToFill()  // Wichtig für Rundung
                                    .frame(width: 50, height: 50)
                                    .background(Color.black.opacity(0.3))

                            }

                            // NAME & STATS
                            VStack(spacing: 4) {
                                Text(hero.name.uppercased())
                                    .font(
                                        .system(
                                            size: 14,
                                            weight: .black,
                                            design: .monospaced
                                        )
                                    )
                                    .foregroundColor(
                                        isSelected ? .white : .gray
                                    )
                                    .lineLimit(1)

                                // Kleine runde Stat-Pille
                                HStack(spacing: 8) {
                                    HStack(spacing: 2) {
                                        Image(systemName: "bolt.fill")
                                        Text("\(Int(hero.attackPower))")
                                    }
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        isSelected
                                            ? accentColor.opacity(0.2)
                                            : Color.white.opacity(0.05)
                                    )
                                    .foregroundColor(
                                        isSelected ? accentColor : .gray
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        // Hintergrund-Kapsel für das gesamte Item
                        .background(
                            Capsule()
                                .fill(
                                    isSelected
                                        ? Color.white.opacity(0.08)
                                        : Color.clear
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
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
