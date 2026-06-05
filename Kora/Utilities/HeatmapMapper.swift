//
//  HeatmapMapper.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Foundation

// snapshot of session data for visual time block
struct SessionBlock {
    let duration: TimeInterval
    let name: String
    let colour: String?
}

// get daily hours and sessions
struct HeatmapMapper {
    static func map(sessions: [StudySession], courses: [Course]) -> (dailyTotals: [Date: TimeInterval], dailySessions: [Date: [SessionBlock]]) {
        
        var dailyTotals: [Date: TimeInterval] = [:]
        var dailySessions: [Date: [SessionBlock]] = [:]
        
        var courseLookup: [UUID: Course] = [:]

        for course in courses {
            courseLookup[course.id] = course
        }
        
        for session in sessions {
            let sessionDay = Calendar.current.startOfDay(for: session.start)
            guard let courseId = session.courseId,
                  let sessionCourse = courseLookup[courseId] else { continue }
            
            dailyTotals[sessionDay, default: 0] += session.duration.rounded(.down)
            
            let block = SessionBlock(duration: session.duration.rounded(.down), name: sessionCourse.name, colour: sessionCourse.colour)
            dailySessions[sessionDay, default: []].append(block)
        }
        return (dailyTotals, dailySessions)
    }
}
