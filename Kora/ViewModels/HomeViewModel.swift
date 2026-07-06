//
//  HomeViewModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

// list of courses, totals, timers

import Foundation
import Observation
import SwiftData

@Observable
final class HomeViewModel {
    
    let timer = TimerEngine()
    
    var totalTime: TimeInterval { timer.totalTime }
    var breakTime: TimeInterval { timer.breakTime }
    var currentBreakTime: TimeInterval { timer.currentBreakTime }
    
    var onBreak: Bool { timer.runningCourse == nil }
    
    func isRunning(_ course: Course) -> Bool {
        timer.runningCourse == course.id
    }
    
    func courseTime(for course: Course) -> TimeInterval {
        timer.courseTime(for: course.id)
    }
    
    func toggleCourse(_ course: Course) {
        timer.toggleCourse(course.id)
    }
    
    func newDay() {
        timer.newDay()
    }
    
    func setup(context: ModelContext) {        
        let todayStart = Calendar.current.studyDayStart(for: Date.now)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
        let lowerBound = Calendar.current.date(byAdding: .day, value: -1, to: todayStart)!

        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in session.start >= lowerBound && session.start < dayEnd }
        )

        if let sessions = try? context.fetch(descriptor) {
            var totals: [UUID: TimeInterval] = [:]
            for session in sessions {
                guard let courseId = session.courseId else { continue }
                let end = session.start.addingTimeInterval(session.duration)
                let contribution = min(end, dayEnd).timeIntervalSince(max(session.start, todayStart))
                guard contribution > 0 else { continue }
                totals[courseId, default: 0] += contribution.rounded(.down)
            }
            timer.loadCourseTimes(totals)
        }
    }
    
    func saveSession(context: ModelContext) {
        timer.onSessionEnd = { courseId, startDate, endDate in
            let session = StudySession(courseId: courseId, start: startDate, end: endDate, isCompleted: true)
            
            context.insert(session)
        }
    }
}
