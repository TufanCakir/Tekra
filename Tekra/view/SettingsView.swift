//
//  SettingsView.swift
//  Tekra
//
//  Created by Tufan Cakir on 11.01.26.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("musicOn") var musicOn = true
    @AppStorage("soundOn") var soundOn = true
    @AppStorage("vibrationOn") var vibrationOn = true
    @AppStorage("brightness") var brightness: Double = 0.8

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [.black, .blue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                Text("SETTINGS")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan, radius: 20)
                    .padding(.top)

                SettingsToggle(
                    title: "MUSIC",
                    systemImage: "music.note",
                    isOn: $musicOn
                )
                SettingsToggle(
                    title: "SOUND FX",
                    systemImage: "speaker.wave.2.fill",
                    isOn: $soundOn
                )
                SettingsToggle(
                    title: "VIBRATION",
                    systemImage: "iphone.radiowaves.left.and.right",
                    isOn: $vibrationOn
                )

                VStack(alignment: .leading) {
                    Text("BRIGHTNESS")
                        .foregroundColor(.white)
                    Slider(value: $brightness)
                }
                .padding()

                Spacer()
            }
            .padding()
        }
    }
}
