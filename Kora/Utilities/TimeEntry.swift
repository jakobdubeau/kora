//
//  TimeEntry.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-08-14.
//

import Foundation

// time input logic for hour/mins
enum TimeSegment {
    case hour, minute

    var maxValue: Int { self == .hour ? 12 : 59 }

    func clamp(_ value: Int) -> Int {
        if self == .hour && value == 0 { return 12 }
        return min(value, maxValue)
    }

    // strips non digits, caps at two, and pads a first digit that can only be itself (runs every keystroke)
    func clean(_ text: String) -> String {
        let digits = String(text.filter(\.isNumber).prefix(2))
        guard let value = Int(digits) else { return "" }
        if digits.count == 1 && value * 10 <= maxValue { return digits }
        return String(format: "%02d", clamp(value))
    }

    // commits a half typed segment when the caret leaves it (runs after leaving focus on the field)
    func normalize(_ text: String) -> String {
        guard let value = Int(text) else { return "" }
        return String(format: "%02d", clamp(value))
    }
}

struct TimeEntry {

    var hour = ""
    var minute = ""
    var isPM: Bool
    let initial: Date

    // derives isPM so toggle doesn't flash when drawn
    init(_ initial: Date) {
        self.initial = initial
        self.isPM = Calendar.current.component(.hour, from: initial) >= 12
    }

    var hourPlaceholder: String {
        let hour = Calendar.current.component(.hour, from: initial)
        return String(format: "%02d", hour % 12 == 0 ? 12 : hour % 12)
    }

    var minutePlaceholder: String {
        String(format: "%02d", Calendar.current.component(.minute, from: initial))
    }

    var hour12: Int { Int(hour.isEmpty ? hourPlaceholder : hour) ?? 0 }
    var minutes: Int { Int(minute.isEmpty ? minutePlaceholder : minute) ?? 0 }

    func text(for segment: TimeSegment) -> String {
        segment == .hour ? hour : minute
    }

    // user shouldn't have to remove the padded 0 added on
    func trimmed(for segment: TimeSegment) -> String {
        let shorter = String(text(for: segment).dropLast())
        return shorter == "0" ? "" : shorter
    }
}
