//
//  EventFlowView.swift
//  Tekra
//
//  Created by Tufan Cakir on 18.01.26.
//

import SwiftUI

struct EventFlowView: View {
    @Environment(GameEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    let event: GameEvent

    @State private var characterChosen = false

    var body: some View {
        ZStack {
            if characterChosen {
                EventBattleView(event: event)
            } else {
                VStack {
                    CharacterPickerView()

                    Button {
                        guard engine.currentPlayer != nil else { return }
                        withAnimation(.easeOut(duration: 0.25)) {
                            characterChosen = true
                        }
                    } label: {
                        Text("CONFIRM CHARACTER")
                            .font(
                                .system(
                                    size: 16,
                                    weight: .black,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(14)
                            .padding()
                    }
                }
                .background(Color.black.ignoresSafeArea())
            }
        }
    }
}
