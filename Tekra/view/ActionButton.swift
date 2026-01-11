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
            Text(title)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color(hex: theme.text.primary))
                .frame(width: 140, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .fill(Color(hex: set.core))
                        .shadow(color: Color(hex: set.glow), radius: 16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(theme.chromeGradient(), lineWidth: 2)
                )
        }
    }
}
