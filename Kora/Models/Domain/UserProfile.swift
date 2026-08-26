//
//  UserProfile.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

// preferences and identity (seperate from auth)

import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var username: String
    var avatarURL: URL?
    var bannerURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarURL = "avatar_url"
        case bannerURL = "banner_url"
    }
}
