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
        dailySessions[day] ?? []
    }

    func setup(context: ModelContext, selectedMonth: Date) {

        let month = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedMonth))!
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: month)!
        let monthStart = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: month)!
        let nextMonthStart = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: nextMonth)!

        // query
        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in session.start >= monthStart && session.start < nextMonthStart }
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

        // start monthly heatmap at the yearly month where user first used app
        let yearStart = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: month))!
        let yearEnd = Calendar.current.date(byAdding: .year, value: 1, to: yearStart)!
        let yearStarted = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: yearStart)!
        let yearEnded = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: yearEnd)!
        let yearDescriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in session.start >= yearStarted && session.start < yearEnded }
        )
        if let yearSessions = try? context.fetch(yearDescriptor) {
            firstActiveMonth = yearSessions.map { Calendar.current.studyDayStart(for: $0.start) }
                .min()
                .map { Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: $0))! }
        }
    }
}
