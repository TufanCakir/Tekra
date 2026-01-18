//
//  RaidListView.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import SwiftUI

struct RaidListView: View {
    @Environment(GameEngine.self) private var engine
    @State private var selectedBoss: RaidBoss?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, Color.black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    header

                    VStack(spacing: 20) {
                        ForEach(
                            FighterRegistry.currentRaidBosses.values.sorted {
                                $0.name < $1.name
                            }
                        ) { boss in
                            RaidCard(boss: boss) {
                                selectedBoss = boss
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationDestination(item: $selectedBoss) { boss in
            RaidFlowView(boss: boss)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("RAIDS")
                .font(.system(size: 30, weight: .black, design: .monospaced))
                .foregroundColor(.white)

            Text("ENDGAME BOSSES")
                .font(.caption.bold())
                .foregroundColor(.red)

            Text("Massive enemies.\nOnly the strongest survive.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }
}
