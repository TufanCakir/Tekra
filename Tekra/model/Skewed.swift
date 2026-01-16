//
//  Skewed.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftUI

// MARK: - Skew Support
struct Skewed: ViewModifier {
    let degrees: Double
    func body(content: Content) -> some View {
        content.projectionEffect(
            ProjectionTransform(
                CGAffineTransform(
                    a: 1,
                    b: 0,
                    c: CGFloat(tan(degrees * .pi / 180)),
                    d: 1,
                    tx: 0,
                    ty: 0
                )
            )
        )
    }
}

extension View {
    func skewed(degrees: Double) -> some View {
        self.modifier(Skewed(degrees: degrees))
    }
}
