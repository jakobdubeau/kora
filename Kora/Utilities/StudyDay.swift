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
    func studyDaySplit(start: Date, end: Date) -> [(dayStart: Date, start: Date, duration: TimeInterval)] {
        var split: [(dayStart: Date, start: Date, duration: TimeInterval)] = []
        var splitStart = start
        while splitStart < end {
            let dayStart = studyDayStart(for: splitStart)
            let nextDay = self.date(byAdding: .day, value: 1, to: dayStart)!
            let splitEnd = min(end, nextDay)
            split.append((dayStart, splitStart, splitEnd.timeIntervalSince(splitStart)))
            splitStart = splitEnd
        }
        return split
    }
}
