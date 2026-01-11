//
//  GameBoyView.swift
//  Tekra
//
//  Created by Tufan Cakir on 10.01.26.
//

import SwiftUI

struct GameBoyView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Außenbezel
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            // SCREEN BORDER
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .padding()

            // GAME SCREEN
            content
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
        }
        .frame(width: 420, height: 240)
    }
}

#Preview {
    GameBoyView {

    }
}
