//
//  ArcadeActionButton.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//
import SwiftUI

struct ArcadeActionButton: View {

    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color, .black],
                            center: .topLeading,
                            startRadius: 6,
                            endRadius: 42
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: color.opacity(0.9), radius: 16)

                Text(title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                    .shadow(radius: 4)
            }
        }
    }
}
