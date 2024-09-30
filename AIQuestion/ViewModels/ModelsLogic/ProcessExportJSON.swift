//
//  ProcessExportJSON.swift
//  AIQuestion
//
//  Created by Jose Decena on 27/9/24.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

final class ProcessExportJSON {
    func transformAnswersJSON(answers: [Answers]) -> [AnswerDTO] {
        
        return answers.map { ans in
            
            let strAnswers: [StrAnswerDTO] = ans.answers!.map {
                StrAnswerDTO(str: $0.str)
            }
            return AnswerDTO(id: ans.id, title: ans.title, possibleAnswers: strAnswers, answer: ans.answer, learningLevel: ans.learningLevel, dateCreate: ans.dateCreate, lastTimeAsked: ans.lastTimeAsked, isFavorite: ans.isFavorite)
        }
    }
    
    func transformTopicsJSON(topics: [Topics]) -> [TopicDTO] {
        var auxTopics: [TopicDTO] = []
        for topic in topics {
            let auxAnswers: [AnswerDTO] = transformAnswersJSON(answers: topic.answers!)
            let auxTopic = TopicDTO(id: topic.id, title: topic.title, answers: auxAnswers, dateCreate: topic.dateCreate, lastTimeAsked: topic.lastTimeAsked, note: topic.note, isFavorite: topic.isFavorite)
            auxTopics.append(auxTopic)
        }
        return auxTopics
    }
    
    func transformBooksJSON(books: [Books]) -> [BookDTO] {
        func transformBooksJSON(book: Books) -> BookDTO {
            BookDTO(id: book.id, title: book.title, topics: transformTopicsJSON(topics: book.topics!), dateCreate: book.dateCreate, lastTimeAsked: book.lastTimeAsked, note: book.note, isFavorite: book.isFavorite)
        }
        let auxBooks = books.map { book in
            transformBooksJSON(book: book)
        }
        print(auxBooks.first?.topics ?? "Esport is empty")
        return auxBooks
    }
}

struct JSONFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var url: URL

    init(url: URL) {
        self.url = url
    }

    init(configuration: ReadConfiguration) throws {
        fatalError("No soportado en esta implementación.")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: url, options: .immediate)
    }
}
