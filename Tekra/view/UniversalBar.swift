//
//  UniversalBar.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct UniversalBar: View {
    var progress: CGFloat
    var core: String
    var glow: String

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.35))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: core), Color(hex: glow)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
                    .shadow(color: Color(hex: glow), radius: 12)
            }
        }
        .frame(height: 18)
    }
}
