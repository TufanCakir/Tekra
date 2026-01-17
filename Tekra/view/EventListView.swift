//
//  EventListView.swift
//  Tekra
//
//  Created by Tufan Cakir on 17.01.26.
//

import SwiftUI

struct EventListView: View {
    @Environment(GameEngine.self) private var engine
    @State private var events: [GameEvent] = []
    @State private var selectedEvent: GameEvent?

    var body: some View {
        ZStack {
            // MARK: - Background
            LinearGradient(
                colors: [.black, Color.black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // MARK: - Header
                    header

                    // MARK: - Events
                    VStack(spacing: 18) {
                        ForEach(events.filter { $0.active }) { event in
                            EventCard(event: event) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    selectedEvent = event
                                }
                            }
                            .transition(
                                .opacity.combined(with: .move(edge: .bottom))
                            )
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            events = EventLoader.load()
        }
        .navigationDestination(item: $selectedEvent) { event in
            EventBattleView(event: event)
        }
    }

    // MARK: - Header View
    private var header: some View {
        VStack(spacing: 10) {

            Text("WORLD EVENTS")
                .font(.system(size: 30, weight: .black, design: .monospaced))
                .foregroundColor(.white)

            Text("LIMITED OPERATIONS")
                .font(.caption.bold())
                .foregroundColor(.purple)

            Text(
                "Special missions with unique rewards.\nAvailable for a limited time."
            )
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.top, 4)
        }
        .padding(.top, 24)
    }
}
