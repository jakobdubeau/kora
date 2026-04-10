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
        let today = Calendar.current.startOfDay(for: Date.now)
        
        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in session.start >= today }
        )
                                         
            if let sessions = try? context.fetch(descriptor) {
                var totals: [UUID: TimeInterval] = [:]
                for session in sessions {
                    if let courseId = session.courseId {
                        totals[courseId, default: 0] += session.duration
                    }
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
