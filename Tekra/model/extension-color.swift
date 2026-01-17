//
//  extension-color.swift
//  Tekra
//
//  Created by Tufan Cakir on 16.01.26.
//

import SwiftUI

extension Color {

    init(hex: String) {
        let cleaned =
            hex
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            .uppercased()

        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r: UInt64
        let g: UInt64
        let b: UInt64
        let a: UInt64

        switch cleaned.count {

        case 3:  // RGB (12-bit) #RGB
            r = ((value >> 8) & 0xF) * 17
            g = ((value >> 4) & 0xF) * 17
            b = (value & 0xF) * 17
            a = 255

        case 6:  // RGB (24-bit) #RRGGBB
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
            a = 255

        case 8:  // ARGB (32-bit) #AARRGGBB
            a = (value >> 24) & 0xFF
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF

        default:
            // 🔒 Fallback: sichtbares Magenta (Debug-freundlich)
            self = Color.black
            return
        }

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
