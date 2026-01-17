//
//  BattleArenaView.swift
//  Tekra
//
//  Created by Tufan Cakir on 15.01.26.
//

import SwiftData
import SwiftUI

struct BattleArenaView: View {
    // MARK: - Dependencies
    var engine: GameEngine
    var showDefaultHUD: Bool = true

    // MARK: - Layout Constants
    private struct Layout {
        static let cornerRadiusFactor: CGFloat = 0.05
        static let groundYOffsetFactor: CGFloat = 0.0
        static let fighterHeightFactor: CGFloat = 0.3
        static let floorShadowWidthFactor: CGFloat = 0.3
        static let floorShadowHeightFactor: CGFloat = 0.03
        static let playerXOffsetFactor: CGFloat = 0.22
        static let enemyXOffsetFactor: CGFloat = 0.22
        static let nameFontFactor: CGFloat = 0.1
        static let hpBarHeightFactor: CGFloat = 0.1
        static let topPaddingFactor: CGFloat = 0.05
        static let horizontalPaddingFactor: CGFloat = 0.05
        static let roundFontFactor: CGFloat = 0.025
        static let timerFontFactor: CGFloat = 0.06
        static let hitSparkRadiusFactor: CGFloat = 0.1
        static let hitSparkWidthFactor: CGFloat = 0.2
        static let backgroundYOffsetFactor: CGFloat = 0.0
        static let parallaxFactor: CGFloat = 0.1
        static let shadowBlur: CGFloat = 3
        static let fighterShadowRadiusFactor: CGFloat = 0.3
    }

    var body: some View {
        GeometryReader { geo in
            let screen = geo.size
            let cornerRadius = screen.width * Layout.cornerRadiusFactor

            ZStack {
                // 1. DYNAMIC BACKGROUND
                Image(engine.currentBackground)
                    .resizable()
                    .scaledToFill()
                    .frame(width: screen.width, height: screen.height)
                    .scaleEffect(engine.isPerformingAction ? 1.05 : 1.0)
                    .offset(
                        x: -engine.p1X * Layout.parallaxFactor,
                        y: -screen.height * Layout.backgroundYOffsetFactor
                    )
                    .blur(radius: engine.isPerformingAction ? 1 : 0)
                    .accessibilityHidden(true)

                // 2. DYNAMIC FLOOR EFFECTS (Shadows)
                dynamicFloorEffects(in: screen)

                // 3. FIGHTER LAYER
                fighterLayer(in: screen)

                // 4. DYNAMIC HIT VFX
                if engine.isFrozen {
                    hitSpark(in: screen)
                }

                // 5. HUD LAYER
                if showDefaultHUD {
                    hudLayer(in: screen)
                }
            }
            .offset(x: max(-8, min(8, engine.shakeOffset)))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .animation(
                .spring(response: 0.25, dampingFraction: 0.8),
                value: engine.shakeOffset
            )
        }
    }

    // MARK: - Dynamic Fighter Layer
    private func fighterLayer(in size: CGSize) -> some View {
        let groundY = -size.height * Layout.groundYOffsetFactor

        return ZStack(alignment: .bottom) {
            if let player = engine.currentPlayer {
                dynamicFighter(
                    fighter: player,
                    pose: engine.currentPose,
                    isPlayer: true,
                    size: size
                )
                .offset(
                    x: -size.width * Layout.playerXOffsetFactor + engine.p1X,
                    y: groundY - size.height * 0.06  // 👈 DAS ist der Trick
                )
            }

            if let enemy = engine.currentEnemy {
                dynamicFighter(
                    fighter: enemy,
                    pose: engine.enemyPose,  // ✅ RICHTIG
                    isPlayer: false,
                    size: size
                )
                .scaleEffect(x: -1, y: 1)
                .offset(
                    x: size.width * Layout.enemyXOffsetFactor,
                    y: groundY - size.height * 0.06
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func dynamicFighter(
        fighter: Fighter,
        pose: String,
        isPlayer: Bool,
        size: CGSize
    ) -> some View {

        let fighterHeight = size.height * Layout.fighterHeightFactor
        let spriteName = engine.spriteName(for: fighter, pose: pose)

        return Image(engine.spriteName(for: fighter, pose: pose))
            .resizable()
            .scaledToFit()
            .frame(height: fighterHeight)
            .shadow(
                color: (isPlayer ? Color.blue : Color.red).opacity(0.4),
                radius: isPlayer ? 10 : 2
            )
            .id(spriteName)  // 🔥 WICHTIG: erzwingt Pose-Refresh
            .transition(.opacity)
            .animation(.easeOut(duration: 0.15), value: spriteName)
    }

    // MARK: - Dynamic HUD
    private func hudLayer(in size: CGSize) -> some View {
        VStack {
            HStack(alignment: .top) {
                if let player = engine.currentPlayer {
                    dynamicHealthBar(
                        name: player.name,
                        currentHP: engine.playerHP,
                        maxHP: player.maxHP,
                        color: .cyan,
                        reversed: false,
                        width: size.width * 0.35
                    )
                }

                Spacer()

                timerDisplay(size: size)

                Spacer()

                if let enemy = engine.currentEnemy {
                    dynamicHealthBar(
                        name: enemy.name,
                        currentHP: engine.enemyHP,
                        maxHP: enemy.maxHP,
                        color: .red,
                        reversed: true,
                        width: size.width * 0.35
                    )
                }
            }
            .padding(.top, size.height * Layout.topPaddingFactor)
            .padding(.horizontal, size.width * Layout.horizontalPaddingFactor)
            Spacer()
        }
    }

    private func dynamicHealthBar(
        name: String,
        currentHP: CGFloat,
        maxHP: CGFloat,
        color: Color,
        reversed: Bool,
        width: CGFloat
    ) -> some View {
        let clampedHP = max(0, min(currentHP, maxHP))
        let ratio = maxHP > 0 ? clampedHP / maxHP : 0

        return VStack(alignment: reversed ? .trailing : .leading, spacing: 4) {
            Text(name.uppercased())
                .font(
                    .system(
                        size: width * Layout.nameFontFactor,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(.white)
                .italic()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .accessibilityLabel(Text("Name: \(name)"))

            ZStack(alignment: reversed ? .trailing : .leading) {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .frame(
                        width: width,
                        height: width * Layout.hpBarHeightFactor
                    )

                Rectangle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(
                        width: width * ratio,
                        height: width * Layout.hpBarHeightFactor
                    )
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: ratio)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: width * ratio,
                        height: width * Layout.hpBarHeightFactor
                    )
                    .animation(.spring(response: 0.3), value: ratio)
            }
            .skewed(degrees: reversed ? 10 : -10)
            .accessibilityValue(Text("HP: \(Int(clampedHP)) von \(Int(maxHP))"))
        }
    }

    private func timerDisplay(size: CGSize) -> some View {
        VStack(spacing: 2) {
            Text("ROUND 1")
                .font(
                    .system(
                        size: size.width * Layout.roundFontFactor,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundStyle(.secondary)
                .accessibilityLabel(Text("Runde 1"))
            Text("99")
                .font(
                    .system(
                        size: size.width * Layout.timerFontFactor,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundColor(.yellow)
                .accessibilityLabel(Text("Zeit: 99"))
        }
    }

    private func dynamicFloorEffects(in size: CGSize) -> some View {
        let groundY = -size.height * Layout.groundYOffsetFactor
        let shadowWidth = size.width * Layout.floorShadowWidthFactor
        let shadowHeight = size.height * Layout.floorShadowHeightFactor

        return ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(0.3))
                .frame(width: shadowWidth, height: shadowHeight)
                .blur(radius: Layout.shadowBlur)
                .offset(
                    x: -size.width * Layout.playerXOffsetFactor + engine.p1X,
                    y: groundY + 5
                )

            Ellipse()
                .fill(Color.black.opacity(0.3))
                .frame(width: shadowWidth, height: shadowHeight)
                .blur(radius: Layout.shadowBlur)
                .offset(
                    x: size.width * Layout.enemyXOffsetFactor,
                    y: groundY + 5
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func hitSpark(in size: CGSize) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.white, .yellow, .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width * Layout.hitSparkRadiusFactor
                )
            )
            .frame(width: size.width * Layout.hitSparkWidthFactor)
            .offset(x: size.width * 0.15, y: -size.height * 0.1)
            .transition(.scale.combined(with: .opacity))
            .animation(.easeOut(duration: 0.25), value: engine.isFrozen)
            .accessibilityHidden(true)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PlayerProgress.self,
        configurations: config
    )
    let engine = GameEngine()

    BattleArenaView(engine: engine)
        .environment(engine)
        .modelContainer(container)
}
