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
