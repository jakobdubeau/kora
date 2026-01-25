//
//  TimeFormatter.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Foundation

func formatTime(seconds: Double) -> String {
    let minutes = Int(seconds) / 60
    let remainingSeconds = Int(seconds) % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}
