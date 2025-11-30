//
//  Announcement.swift
//  Esprit Ios
//
//  Created by mac air  on 22/11/2025.
//

import Foundation

struct Announcement: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let audience: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case content
        case audience
        case createdAt
    }
}
