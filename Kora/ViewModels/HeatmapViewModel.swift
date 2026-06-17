//
//  HeatmapViewModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Foundation
import Observation
import SwiftData

@Observable
final class HeatmapViewModel {
    
    var dailyTotals: [Date: TimeInterval] = [:]
    var dailySessions: [Date: [SessionBlock]] = [:]
    var firstActiveMonth: Date?
        
    func sessions(for day: Date) -> [SessionBlock] {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: day)!

        let normal = (dailySessions[day] ?? []).filter {
            Calendar.current.component(.hour, from: $0.start) >= 5
        }

        let earlyMorning = (dailySessions[day] ?? []).compactMap { block -> SessionBlock? in
            guard Calendar.current.component(.hour, from: block.start) < 5 else { return nil }
            let dayStart = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: block.start)!
            let remaining = block.start.addingTimeInterval(block.duration).timeIntervalSince(dayStart)
            guard remaining > 0 else { return nil }
            return SessionBlock(duration: remaining, start: dayStart, name: block.name, colour: block.colour)
        }

        let lateNight = (dailySessions[nextDay] ?? []).compactMap { block -> SessionBlock? in
            guard Calendar.current.component(.hour, from: block.start) < 5 else { return nil }
            let dayStart = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: block.start)!
            let trimmed = min(block.duration, dayStart.timeIntervalSince(block.start))
            guard trimmed > 0 else { return nil }
            return SessionBlock(duration: trimmed, start: block.start, name: block.name, colour: block.colour)
        }

        return normal + earlyMorning + lateNight
    }

    func setup(context: ModelContext, selectedMonth: Date) {

        let month = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedMonth))!
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: month)!
        
        // query
        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in session.start >= month && session.start < nextMonth }
        )
                         
        // how we actually fetch sessions from swiftData, becomes an array
        if let sessions = try? context.fetch(descriptor) {
            
            let courseDescriptor = FetchDescriptor<Course>()
            
            if let courses = try? context.fetch(courseDescriptor) {
                
                // once we filled the arrays we can work with them
                let res = HeatmapMapper.map(sessions: sessions, courses: courses)
                dailyTotals = res.dailyTotals
                dailySessions = res.dailySessions
            }
        }

        // to start monthly heatmap at month user first used the app of the year
        let yearStart = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: month))!
        let yearEnd = Calendar.current.date(byAdding: .year, value: 1, to: yearStart)!
        let yearDescriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in session.start >= yearStart && session.start < yearEnd }
        )
        if let yearSessions = try? context.fetch(yearDescriptor) {
            firstActiveMonth = yearSessions.map { Calendar.current.startOfDay(for: $0.start) }
                .min()
                .map { Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: $0))! }
        }
    }
}
