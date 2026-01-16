//
//  TekraApp.swift
//  Tekra
//
//  Created by Tufan Cakir on 10.01.26.
//

import SwiftData
import SwiftUI

@main
struct TekraApp: App {
    // 1. Die Engine hier einmalig erstellen
    @State private var engine = GameEngine()

    var body: some Scene {
        WindowGroup {
            RootView()
                // 2. WICHTIG: Nutze .environment() OHNE "Object" am Ende
                .environment(engine)
                .modelContainer(for: PlayerProgress.self)
        }
    }
}
