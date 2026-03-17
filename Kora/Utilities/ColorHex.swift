//
//  ColorHex.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI

extension Color {
    static let palettes: [(name: String, shades: [String])] = [
        ("red",    ["#FFCDD2", "#EF9A9A", "#EF5350", "#E53935", "#B71C1C"]),
        ("orange", ["#FFE0B2", "#FFCC80", "#FFA726", "#FB8C00", "#E65100"]),
        ("yellow", ["#FFF9C4", "#FFF176", "#FFEE58", "#FDD835", "#F9A825"]),
        ("green",  ["#C8E6C9", "#81C784", "#66BB6A", "#43A047", "#1B5E20"]),
        ("teal",   ["#B2DFDB", "#80CBC4", "#4DB6AC", "#00897B", "#004D40"]),
        ("blue",   ["#BBDEFB", "#64B5F6", "#42A5F5", "#1E88E5", "#0D47A1"]),
        ("purple", ["#E1BEE7", "#CE93D8", "#AB47BC", "#8E24AA", "#4A148C"]),
        ("pink",   ["#F8BBD0", "#F48FB1", "#EC407A", "#D81B60", "#880E4F"]),
    ]
}
