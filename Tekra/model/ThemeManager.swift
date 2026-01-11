//
//  TekraThemeManager.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

internal import Combine
import Foundation
import SwiftUI

final class ThemeManager: ObservableObject {
    @Published private(set) var current: Theme

    init(theme: Theme) {
        self.current = theme
    }

    func setTheme(_ theme: Theme) {
        withAnimation(.easeInOut(duration: 0.35)) {
            current = theme
        }
    }
}
