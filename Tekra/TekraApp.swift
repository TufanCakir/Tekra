//
//  TekraApp.swift
//  Tekra
//
//  Created by Tufan Cakir on 10.01.26.
//

import SwiftUI

@main
struct TekraApp: App {

    @StateObject private var themeManager =
        ThemeManager(theme: ThemeLoader.load())

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(themeManager)   // 🌍 Global Theme
        }
    }
}
