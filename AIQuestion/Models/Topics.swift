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
    var id: UUID = UUID()
    @Attribute(.spotlight) var title: String = ""
    var book: Books? = nil
    @Relationship(deleteRule: .cascade, inverse: \Answers.topic) var answers: [Answers]? = nil
    var dateCreate: Date = Date()
    var lastTimeAsked: Date = Date()
    var note: String? = nil
    var isFavorite: Bool = false
    
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

struct SimpleTopicDTO: Codable {
    let title: String
    let answers: [SimpleAnswerDTO]
}

