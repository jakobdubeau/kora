//
//  TimeFormatter.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Foundation

func formatTime(seconds: TimeInterval) -> String {
    
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    let remainingSeconds = Int(seconds) % 60
    
    return String(format: "%2d:%02d:%02d", hours, minutes, remainingSeconds)
}

func formatTimeBreak(seconds: TimeInterval) -> String {
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    let remainingSeconds = Int(seconds) % 60

    if Int(seconds) < 60 {
        return String(format: "%ds", remainingSeconds)
    }
    else if Int(seconds) < 3600 {
        return String(format: "%dm %ds", minutes, remainingSeconds)
    }
    else {
        return String(format: "%dh %dm", hours, minutes)
    }
}
