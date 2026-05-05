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
    
    var onSessionEnd: ((UUID, Date, Date) -> Void)? // closure to save study sessions
    
    // MARK: - Public observable state
    
    private(set) var runningCourse: UUID? = nil // current running course by id
    private(set) var courseTimes: [UUID: TimeInterval] = [:] // dictionary to map course id to seconds while active
    private(set) var totalBreakTime: TimeInterval = 0 // total break time, not bounded by courses
    
    // MARK: - Private bookkeeping
    
    private var sessionStartTime: TimeInterval? = nil
    private var sessionStartDate: Date? = nil
    private var breakStartTime: TimeInterval? = nil
    
    private var currentTime: TimeInterval = ProcessInfo.processInfo.systemUptime
    
    private var timer: Timer? // ui
    
    private let maxBreak: TimeInterval = 3600 // 1 hour, max time to be counted as a break vs completely new session
    
    // MARK: - Computed values
    
    // cumulative time tracked
    var totalTime: TimeInterval {
        var total = courseTimes.values.reduce(0, +) // sum up all stored courseTime dict values (TimeIntervals)
        
        if runningCourse != nil, // if there's a running course
           let start = sessionStartTime { // and has start time
            total += (currentTime - start) // add the current running course to total
        }
    
        return total
    }
    
    var currentSessionTime: TimeInterval {
        if runningCourse != nil,
           let start = sessionStartTime {
            return currentTime - start
        }
        return 0
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
    var breakTime: TimeInterval {
        if runningCourse == nil, // if no running course
           let start = breakStartTime { // if there's a start time
            return totalBreakTime + (currentTime - start) // stored breaktime + current break time
        }
        
        return totalBreakTime // stored break time
    }
    
    var currentBreakTime: TimeInterval {
        if runningCourse == nil,
           let start = breakStartTime {
            return currentTime - start
        }
        return 0
    }
    
    // MARK: - Main timer interaction
    func toggleCourse(_ course: UUID) {
        let current = ProcessInfo.processInfo.systemUptime // capture current time
        let lastTick = currentTime
        currentTime = current

        // Case 1: tap currently running course button, start break
        if runningCourse == course {
            stopRunningCourse(at: lastTick)
            startBreak(at: current)
            runningCourse = nil
            sessionStartTime = nil
            sessionStartDate = nil
            
            startTimer()
            return
        }
        
        // Case 2: tapping a different course while one is running, switch courses (no break)
        if runningCourse != nil {
            stopRunningCourse(at: current)
            runningCourse = course
            sessionStartTime = current
            sessionStartDate = Date.now
            
            breakStartTime = nil
            
            startTimer()
            return
        }
        
        // Case 3: start new course while nothing is running, either brand new or back from break
        stopBreak(at: current)
        runningCourse = course
        sessionStartTime = current
        sessionStartDate = Date.now
        
        startTimer()
        
    }
    
    // MARK: - Close sessions
    
    private func stopRunningCourse(at current: TimeInterval) {
        guard let running = runningCourse,
              let start = sessionStartTime else { return }
        
        let elapsed = (current - start).rounded(.down)
        courseTimes[running, default: 0] += elapsed
        
        if let startDate = sessionStartDate {
            onSessionEnd?(running, startDate, Date.now)
        }
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
        sessionStartDate = nil
        breakStartTime = nil
        
        stopTimer()
        currentTime = current
    }
    
    func loadCourseTimes(_ times: [UUID: TimeInterval]) {
        courseTimes = times
    }
    
    // MARK: - Timer UI
    
    private func startTimer() { // updates current time
        guard timer == nil else { return } // we only create timer if one doesn't exist already
        
        // closure = code you give to something else, so it can run it later
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in  // timer runs the closure every second,
            guard let self else { return } // weak references can dissapear                 // when it runs, it passes itself in (timer)
            // closure                    // we need to check if engine is gone            // "_" because we don't need the timer itself
            self.currentTime = ProcessInfo.processInfo.systemUptime                       // since closure owns self, this creates a
        }                                                                                // retain cycle, nothing can be destroyed
                                                                                        // weak lets us access self, but not force alive
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
