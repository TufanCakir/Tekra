//
//  JoystickButton.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct ArcadeStick: View {

    let onPower: (CGFloat) -> Void  // 0.0 – 1.0
    @State private var drag: CGSize = .zero

    let limit: CGFloat = 32

    var body: some View {
        ZStack {
            Circle()
                .fill(.gray.opacity(0.35))
                .frame(width: 110, height: 110)

            Circle()
                .fill(.red)
                .frame(width: 42, height: 42)
                .offset(drag)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            let dx = min(
                                max(v.translation.width, -limit),
                                limit
                            )
                            let dy = min(
                                max(v.translation.height, -limit),
                                limit
                            )

                            drag = CGSize(width: dx, height: dy)

                            let distance = sqrt(dx * dx + dy * dy)
                            let power = min(distance / limit, 1)
                            onPower(power)
                        }
                        .onEnded { _ in
                            drag = .zero
                            onPower(0)
                        }
                )
        }
    }
}
