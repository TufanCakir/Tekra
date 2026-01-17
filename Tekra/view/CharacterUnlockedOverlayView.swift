//
//  CharacterUnlockedOverlayView.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct CharacterUnlockedOverlayView: View {
    let fighter: Fighter
    let onContinue: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 28) {

                Text("NEW CHARACTER UNLOCKED")
                    .font(
                        .system(size: 22, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.yellow)
                    .italic()

                // Portrait
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 140, height: 140)

                    Image(fighter.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                }
                .scaleEffect(scale)
                .opacity(opacity)

                Text(fighter.name.uppercased())
                    .font(
                        .system(size: 20, weight: .black, design: .monospaced)
                    )
                    .foregroundColor(.white)

                Button {
                    onContinue()
                } label: {
                    Text("CONTINUE")
                        .font(
                            .system(
                                size: 18,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.black)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 14)
                        .background(Color.yellow)
                        .cornerRadius(14)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                scale = 1
                opacity = 1
            }
        }
    }
}
