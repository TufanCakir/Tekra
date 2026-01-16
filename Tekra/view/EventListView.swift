//
//  EventListView.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftData
import SwiftUI

struct EventListView: View {
    @Environment(GameEngine.self) private var engine
    @State private var availableEvents: [GameEvent] = []
    @State private var selectedEvent: GameEvent?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(availableEvents.filter { $0.active }) { event in
                        EventCard(event: event) {
                            // Hier den Namen anpassen:
                            engine.loadEvent(event)
                            selectedEvent = event
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("WORLD EVENTS")
            .fullScreenCover(item: $selectedEvent) { event in
                EventBattleView(event: event)  // Hier das Event übergeben
                    .environment(engine)
            }
            .onAppear {
                // Lade Events aus menu.json oder events.json
                self.availableEvents = EventLoader.load()
            }
        }
    }
}

#Preview {
    // 1. Erstelle eine Instanz der Engine für die Vorschau
    let previewEngine = GameEngine()

    // 2. Erstelle einen Container für SwiftData (falls benötigt)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PlayerProgress.self,
        configurations: config
    )

    return EventListView()
        .environment(previewEngine)  // Hier wird die Engine injiziert
        .modelContainer(container)
}
