//
//  Item.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 12/9/24.
//

import Foundation
import SwiftData

@Model
final class Answers {
    @Attribute(.unique) var id: UUID
    @Attribute(.spotlight) var title: String
    var topic: Topics?
    var answers: [StrAnswer]
    var answer: Int
    var learningLevel: Int
    var dateCreate: Date
    var lastTimeAsked: Date
    var isFavorite: Bool
    
    init(id: UUID, title: String, topic: Topics? = nil, answers: [String], answer: Int, learningLevel: Int, dateCreate: Date, lastTimeAsked: Date, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.topic = topic
        let parseAnswers = answers.map { ans in
            StrAnswer(str: ans)
        }
        self.answers = parseAnswers
        self.answer = answer
        self.learningLevel = learningLevel
        self.dateCreate = dateCreate
        self.lastTimeAsked = lastTimeAsked
        self.isFavorite = isFavorite
    }
    
    convenience init(_ title: String, answers: [String], answer: Int) {
        self.init(id: UUID(), title: title, answers: answers, answer: answer, learningLevel: 20, dateCreate: Date(), lastTimeAsked: Date())
    }
}

@Model
final class StrAnswer {
    var str: String
    
    init(str: String) {
        self.str = str
    }
}

struct AnswerDTO: Codable {
    let id: UUID
    let title: String
    let possibleAnswers: [StrAnswerDTO]
    let answer: Int
    let learningLevel: Int
    let dateCreate: Date
    let lastTimeAsked: Date
    let isFavorite: Bool
}

struct StrAnswerDTO: Codable {
    let str: String
}
