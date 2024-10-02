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
    var id: UUID = UUID()
    @Attribute(.spotlight) var title: String = ""
    var topic: Topics? = nil
    @Relationship(deleteRule: .cascade, inverse: \StrAnswer.answer) var answers: [StrAnswer]? = nil
    var answer: Int = 0
    var learningLevel: Int = 0
    var dateCreate: Date = Date()
    var lastTimeAsked: Date = Date()
    var isFavorite: Bool = false
    
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
    var answer: Answers? = nil
    var str: String = ""
    
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

struct SimpleAnswerDTO: Codable {
    let title: String
    let possibleAnswers: [String]
    let answer: Int
}
