//
//  GameOverOverlayView.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

// GameOverOverlayView.swift

import SwiftUI

struct GameOverOverlayView: View {
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Text("GAME OVER")
                    .font(
                        .system(size: 36, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.6), radius: 12)

                Text("YOU WERE DEFEATED")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .tracking(1.4)

                Button {
                    onExit()
                } label: {
                    Text("RETURN TO RAID SELECT")
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
                                colors: [.red, .red.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: .red.opacity(0.6), radius: 14)
                }
                .padding(.horizontal, 32)
            }
        }
    }
}
