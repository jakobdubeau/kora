//
//  CourseModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

// local persisted course/subject, home list of courses

import SwiftData
import Foundation

@Model // persistent data model macro, make it storable in db/on disk
class Course {
    var id: UUID
    var name: String // column in swiftdata store, automatically observed
    var colour: String?
    var createdAt: Date
    var dailyTotal: TimeInterval
    
    init(name: String, colour: String? = nil, dailyTotal: TimeInterval = 0) {
        self.id = UUID()
        self.name = name
        self.colour = colour
        self.createdAt = .now
        self.dailyTotal = dailyTotal
    }
}
