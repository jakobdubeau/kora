//
//  TimerEngine.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Foundation
import Observation

@Observable
final class TimerEngine {
    
    // MARK: - Public observable state
    
    private(set) var runningCourse: UUID? = nil // current running course by id
    private(set) var courseTime: [UUID: TimeInterval] = [:] // dictionary to map course name to seconds while active
    private(set) var breakTime: TimeInterval = 0 // total break time, not bounded by courses
    
    // MARK: - Private bookkeeping
    
    private var sessionStartTime: TimeInterval? = nil
    private var breakStartTime: TimeInterval? = nil
    
    private var currentTime: TimeInterval = ProcessInfo.processInfo.systemUptime
    private var timer: Timer?
    
    private let maxBreak: TimeInterval = 3600 // 1 hour, max time to be counted as a break vs completely new session
    
    // MARK: - Computed values
    
    var totalTime: TimeInterval {
        var total = courseTime.values.reduce(0, +) // sum up all stored courseTime dict values (TimeIntervals)
        
        if let runningID = runningCourse, // if there's a running course
           let start = sessionStartTime { // and has start time
            total += (currentTime - start) // add the current running course to total
        }
    
        return total
    }
}
