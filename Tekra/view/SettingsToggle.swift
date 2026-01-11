//
//  SettingsToggle.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct SettingsToggle: View {

    let title: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.cyan)
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .cyan))
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(18)
    }
}
