//
//  Libros.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 12/9/24.
//

import Foundation
import SwiftData

@Model
final class Books {
    @Attribute(.unique) var id: UUID
    @Attribute(.spotlight) var title: String
    @Relationship(deleteRule: .cascade, inverse: \Topics.book) var topics: [Topics]
    var dateCreate: Date
    var lastTimeAsked: Date
    var note: String?
    var isFavorite: Bool
    
    init(id: UUID, title: String, topics: [Topics], dateCreate: Date, lastTimeAsked: Date, note: String? = nil, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.topics = topics
        self.dateCreate = dateCreate
        self.lastTimeAsked = lastTimeAsked
        self.note = note
        self.isFavorite = isFavorite
    }
    
    convenience init(_ title: String, note: String? = nil) {
        self.init(id: UUID(), title: title, topics: [Topics](), dateCreate: Date(), lastTimeAsked: Date(), note: note)
    }
}

struct BookDTO: Codable {
    let id: UUID
    let title: String
    var topics: [TopicDTO]
    var dateCreate: Date
    var lastTimeAsked: Date
    var note: String?
    let isFavorite: Bool
}
