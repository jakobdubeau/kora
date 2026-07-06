//
//  StudyDay.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-07-06.
//

// a "study day" runs 5:00 AM to 4:59 AM the next day, so late-night sessions
// stay grouped with the day they belong to rather than rolling over at midnight

import Foundation

extension Calendar {
    func studyDayStart(for date: Date) -> Date {
        let fiveAM = self.date(bySettingHour: 5, minute: 0, second: 0, of: date)!
        return date < fiveAM ? self.date(byAdding: .day, value: -1, to: fiveAM)! : fiveAM
    }

    // edge case for 4AM > 6AM type
    func studyDaySlices(start: Date, end: Date) -> [(dayStart: Date, start: Date, duration: TimeInterval)] {
        var slices: [(dayStart: Date, start: Date, duration: TimeInterval)] = []
        var sliceStart = start
        while sliceStart < end {
            let dayStart = studyDayStart(for: sliceStart)
            let nextDay = self.date(byAdding: .day, value: 1, to: dayStart)!
            let sliceEnd = min(end, nextDay)
            slices.append((dayStart, sliceStart, sliceEnd.timeIntervalSince(sliceStart)))
            sliceStart = sliceEnd
        }
        return slices
    }
}
