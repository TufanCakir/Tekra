//
//  ActionButton.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

enum TekraEnergy {
    case fire, ice
}

struct ActionButton: View {

    @EnvironmentObject var themeManager: ThemeManager
    var theme: Theme { themeManager.current }

    let title: String
    let energy: TekraEnergy
    let action: () -> Void

    var body: some View {
        let set = energy == .fire ? theme.energy.fire : theme.energy.ice

        Button(action: action) {
            ZStack {
                // Inner Button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: theme.metal.highlight),
                                Color(hex: theme.metal.edgeGlow),
                                Color(hex: theme.metal.shadow),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                    )
                    .overlay(
                        Circle()
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
                    )

                // Title
                Text(title)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color(hex: theme.text.primary))
                    .shadow(radius: 4)
            }
            .frame(width: 92, height: 92)  // 🕹️ Arcade Button Size
        }
    }
}
