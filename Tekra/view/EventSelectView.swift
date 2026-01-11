//
//  EventSelectView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct EventSelectView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var theme: Theme { themeManager.current }

    let events: [GameEvent]
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 16) {

            Text("SELECT EVENT")
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(Color(hex: theme.text.primary))
                .shadow(color: Color(hex: theme.metal.edgeGlow), radius: 20)
                .padding(.top)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(events.indices, id: \.self) { i in
                        let event = events[i]

                        Button {
                            onSelect(i)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(event.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(
                                        Color(hex: theme.text.primary)
                                    )

                                Text(event.description)
                                    .font(.caption)
                                    .foregroundColor(
                                        Color(hex: theme.text.secondary)
                                    )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                ZStack {
                                    theme.chromeGradient()
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.25),
                                            Color.clear,
                                            Color(hex: theme.metal.shadow)
                                                .opacity(0.8),
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            )
                            .cornerRadius(theme.cornerRadius)
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: theme.cornerRadius
                                )
                                .stroke(
                                    Color(hex: theme.metal.edgeGlow),
                                    lineWidth: 2
                                )
                            )
                            .shadow(
                                color: Color(hex: theme.metal.shadow),
                                radius: 12,
                                y: 6
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }
}
