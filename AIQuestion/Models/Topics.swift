//
//  Topics.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 12/9/24.
//

import Foundation
import SwiftData

@Model
final class Topics {
    @Attribute(.unique) var id: UUID
    @Attribute(.spotlight) var title: String
    var book: Books?
    @Relationship(deleteRule: .cascade, inverse: \Answers.topic) var answers: [Answers]
    var dateCreate: Date
    var lastTimeAsked: Date
    var note: String?
    var isFavorite: Bool
    
    init(id: UUID, title: String, book: Books? = nil, answers: [Answers], dateCreate: Date, lastTimeAsked: Date, note: String? = nil, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.book = book
        self.answers = answers
        self.dateCreate = dateCreate
        self.lastTimeAsked = lastTimeAsked
        self.note = note
        self.isFavorite = isFavorite
    }
    
    convenience init(_ title: String, note: String? = nil) {
        self.init(id: UUID(), title: title, answers: [Answers](), dateCreate: Date(), lastTimeAsked: Date(), note: note)
    }
}

struct TopicDTO: Codable {
    let id: UUID
    let title: String
    let answers: [AnswerDTO]
    let dateCreate: Date
    let lastTimeAsked: Date
    let note: String?
    let isFavorite: Bool
}
