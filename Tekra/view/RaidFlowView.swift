//
//  RaidFlowView.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import SwiftUI

struct RaidFlowView: View {
    @Environment(GameEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    let boss: RaidBoss
    @State private var characterChosen = false

    var body: some View {
        ZStack {
            if characterChosen {
                RaidBattleView(boss: boss)
            } else {
                VStack {
                    CharacterPickerView()

                    Button {
                        guard engine.currentPlayer != nil else { return }
                        withAnimation(.easeOut(duration: 0.25)) {
                            characterChosen = true
                        }
                    } label: {
                        Text("ENTER RAID")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .black,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.red, .red.opacity(0.85)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .red.opacity(0.6), radius: 18, y: 8)
                            .padding()
                    }
                }
                .background(Color.black.ignoresSafeArea())
            }
        }
    }
}
