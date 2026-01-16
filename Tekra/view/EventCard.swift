//
//  EventCard.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftUI

struct EventCard: View {
    let event: GameEvent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Hintergrundbild des Events (aus JSON geladen)
                Image(event.background)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title.uppercased())
                        .font(
                            .system(
                                size: 22,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .italic()
                        .foregroundColor(.yellow)

                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            }
            .background(Color.black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .skewed(degrees: -5)  // Dein Tekken-Stil
        }
        .buttonStyle(PlainButtonStyle())
    }
}
