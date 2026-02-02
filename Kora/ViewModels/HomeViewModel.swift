//
//  HomeViewModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

// list of courses, totals, timers

import Foundation
import Observation

// viewmodel creates engine, viewmodel is the only layer that talks to engine directly, the view goes through the viewmodel
final class HomeViewModel {
    
    let timer = TimerEngine()
    
    let demoCourseID = UUID()
    
    var demoCourseTime: TimeInterval {
        timer.courseTime(for: demoCourseID)
    }
    
    var totalTime: TimeInterval { timer.totalTime }
    var breakTime: TimeInterval { timer.breakTime }
    
    var isRunningCourse: Bool {
        timer.runningCourse == demoCourseID
    }
    
    func toggleCourse() {
        timer.toggleCourse(demoCourseID)
    }
    
    func newDay() {
        timer.newDay()
    }
    
}
