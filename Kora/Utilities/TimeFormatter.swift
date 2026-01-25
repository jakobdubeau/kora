//
//  TimeFormatter.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Foundation

func formatTime(seconds: Double) -> String {
    
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    let remainingSeconds = Int(seconds) % 60
    
    return String(format: "%2d:%02d:%02d", hours, minutes, remainingSeconds)
}
