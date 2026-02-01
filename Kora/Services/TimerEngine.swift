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
    private(set) var courseTimes: [UUID: TimeInterval] = [:] // dictionary to map course name to seconds while active
    private(set) var totalBreakTime: TimeInterval = 0 // total break time, not bounded by courses
    
    // MARK: - Private bookkeeping
    
    private var sessionStartTime: TimeInterval? = nil
    private var breakStartTime: TimeInterval? = nil
    
    private var currentTime: TimeInterval = ProcessInfo.processInfo.systemUptime
    private var timer: Timer?
    
    private let maxBreak: TimeInterval = 3600 // 1 hour, max time to be counted as a break vs completely new session
    
    // MARK: - Computed values
    
    // cumulative time tracked
    var totalTime: TimeInterval {
        var total = courseTimes.values.reduce(0, +) // sum up all stored courseTime dict values (TimeIntervals)
        
        if let running = runningCourse, // if there's a running course
           let start = sessionStartTime { // and has start time
            total += (currentTime - start) // add the current running course to total
        }
    
        return total
    }
    
    // live active time for a specific course
    func courseTime(for course: UUID) -> TimeInterval { // take UUID param, output TimeInterval
        
        let stored = courseTimes[course] ?? 0 // if course has a time already, use it, else 0
        
        if runningCourse == course, // if this is the actively running course
            let start = sessionStartTime { // and has a valid start time
            return stored + (currentTime - start) // sum stored and active running time
        }
        
        return stored // if not running, returned the stored time
    }
    
    // live break time
    var breakTime : TimeInterval {
        if runningCourse == nil, // if no running course
           let start = breakStartTime { // if there's a start time
            return totalBreakTime + (currentTime - start) // stored breaktime + current break time
        }
        
        return totalBreakTime // stored break time
    }
    
    func toggleCourse(_ course: UUID) {
        let current = ProcessInfo.processInfo.systemUptime // capture current time
        
        // Case 1: tap currently running course button, start break
        if runningCourse == course {
            stopRunningCourse(at: current)
            startBreak(at: current)
            runningCourse = nil
            sessionStartTime = nil
            
            startTimer()
            return
        }
        
        // Case 2: tapping a different course while one is running, switch courses (no break)
        if let running = runningCourse {
            stopRunningCourse(at: current)
            runningCourse = course
            sessionStartTime = current
            
            breakStartTime = nil
            
            startTimer()
            return
        }
        
        // Case 3: start new course while nothing is running, either brand new or back from break
        stopBreak(at: current)
        runningCourse = course
        sessionStartTime = current
        
        startTimer()
        
    }
    
    // MARK: - Close sessions
    
    private func stopRunningCourse(at current: TimeInterval) {
        guard let running = runningCourse,
              let start = sessionStartTime else { return }
        
        let elapsed = current - start
        courseTimes[running, default: 0] += elapsed
    }
    
    private func startBreak(at current: TimeInterval) {
        breakStartTime = current
    }
    
    private func stopBreak(at current: TimeInterval) {
        guard let start = breakStartTime else { return }
        
        let elapsed = current - start
        
        if elapsed <= maxBreak {
            totalBreakTime += elapsed
        }
        
        breakStartTime = nil
    }
    
    // MARK: - Daily reset
    
    func newDay() {
        let current = ProcessInfo.processInfo.systemUptime
        
        if runningCourse != nil {
            stopRunningCourse(at: current)
        }
        else {
            stopBreak(at: current)
        }
        
        runningCourse = nil
        courseTimes = [:]
        totalBreakTime = 0
        
        sessionStartTime = nil
        breakStartTime = nil
        
        stopTimer()
        currentTime = current
    }
    
    // MARK: - Timer UI
    
    private func startTimer() {
        guard timer == nil else { return } // we only create timer if one doesn't exist already
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.currentTime = ProcessInfo.processInfo.systemUptime
        }
        
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}
