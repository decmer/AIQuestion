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
    var id: UUID = UUID()
    @Attribute(.spotlight) var title: String = ""
    @Relationship(deleteRule: .cascade, inverse: \Topics.book) var topics: [Topics]? = nil
    var dateCreate: Date = Date()
    var lastTimeAsked: Date = Date()
    var note: String? = nil
    var isFavorite: Bool = false
    
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
    let topics: [TopicDTO]
    let dateCreate: Date
    let lastTimeAsked: Date
    let note: String?
    let isFavorite: Bool
}

struct SimpleBookDTO: Codable {
    let title: String
    let topics: [SimpleTopicDTO]
}
