//
//  CourseModel.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

// local persisted course/subject, home list of courses

import SwiftData

@Model // persistent data model macro, make it storable in db/on disk
class Course {
    var name: String // column in swiftdata store, automatically observed
    var colour: String?
    var dailyTotal: Int
    
    
    init(name: String, colour: String? = nil, dailyTotal: Int = 0) {
        self.name = name
        self.colour = colour
        self.dailyTotal = dailyTotal
    }
}
