//
//  HomeViewModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

// list of courses, totals, timers

import Foundation
import Observation

@Observable
final class HomeViewModel {
    
    let timer = TimerEngine()
    
    var totalTime: TimeInterval { timer.totalTime }
    var breakTime: TimeInterval { timer.breakTime }
    
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
    
}
