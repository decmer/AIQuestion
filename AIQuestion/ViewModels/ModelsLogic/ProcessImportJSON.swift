//
//  ProcessJSON.swift
//  AIQuestion
//
//  Created by Jose Decena on 25/9/24.
//

import Foundation
import SwiftData
import SwiftUI

final class ProcessImportJSON {
    
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func processBooksJSON(desde selectedFile: URL, action: @escaping () -> Void) async {
        if selectedFile.startAccessingSecurityScopedResource() {
            guard let restoredData = try? Data(contentsOf: selectedFile) else {
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let usuariosImportados = try? decoder.decode([BookDTO].self, from: restoredData) else {
                return
            }
            await addItems(usuariosImportados, action: action)
        }
        selectedFile.stopAccessingSecurityScopedResource()
    }
    
    func processTopicsJSON(desde selectedFile: URL, book: Books, action: @escaping (Topics) -> Void) async {
        if selectedFile.startAccessingSecurityScopedResource() {
            guard let restoredData = try? Data(contentsOf: selectedFile) else {
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let usuariosImportados = try? decoder.decode([TopicDTO].self, from: restoredData) else {
                return
            }
            await addItems(usuariosImportados, book: book, action: action)
        }
        selectedFile.stopAccessingSecurityScopedResource()
    }
    
    func processAnswerdsJSON(desde selectedFile: URL, topic: Topics, action: @escaping (Answers) -> Void) async {
        if selectedFile.startAccessingSecurityScopedResource() {
            guard let restoredData = try? Data(contentsOf: selectedFile) else {
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let usuariosImportados = try? decoder.decode([AnswerDTO].self, from: restoredData) else {
                return
            }
            await addItems(usuariosImportados, topic: topic, action: action)
        }
        selectedFile.stopAccessingSecurityScopedResource()
    }
    
    func JSONToSwiftData(_ item: AnswerDTO) -> Answers {
        let answers: [String] = item.possibleAnswers.map { answer in
            answer.str
        }
        return Answers(id: item.id, title: item.title, answers: answers, answer: item.answer, learningLevel: item.learningLevel, dateCreate: item.dateCreate, lastTimeAsked: item.lastTimeAsked, isFavorite: item.isFavorite)
    }
    
    func JSONToSwiftData(_ item: TopicDTO) -> Topics {
        let answers: [Answers] = item.answers.map { answer in
            JSONToSwiftData(answer)
        }
        return Topics(id: item.id, title: item.title, answers: answers, dateCreate: item.dateCreate, lastTimeAsked: item.lastTimeAsked, note: item.note, isFavorite: item.isFavorite)
    }
    
    func JSONToSwiftData(_ item: BookDTO) -> Books {

        let topics: [Topics] = item.topics.map { topic in
            JSONToSwiftData(topic)
        }
        return Books(id: item.id, title: item.title, topics: topics, dateCreate: item.dateCreate, lastTimeAsked: item.lastTimeAsked, note: item.note, isFavorite: item.isFavorite)
    }
    
    func addItems(_ items: [BookDTO], action: @escaping () -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueBooks", qos: .utility, attributes: .concurrent)

        let numQueue =  min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    let book = JSONToSwiftData(item)
                    context.insert(book)
                }
                action()
            }
        }
        do {
            try context.save()
        } catch {
            print("SaveError")
        }
    }
    
    func addItems(_ items: [TopicDTO], book: Books, action: @escaping (Topics) -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueTopics", qos: .utility, attributes: .concurrent)

        let numQueue =  min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    let answer = JSONToSwiftData(item)
                    self.context.insert(answer)
                    book.topics.append(answer)
                    action(answer)
                }
            }
        }
        do {
            try context.save()
        } catch {
            print("SaveError")
        }
    }
    
    func addItems(_ items: [AnswerDTO], topic: Topics, action: @escaping (Answers) -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueAnswer", qos: .utility, attributes: .concurrent)
        
        let numQueue = min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    let answer = JSONToSwiftData(item)
                    context.insert(answer)
                    topic.answers.append(answer)
                    action(answer)
                }
            }
        }
        do {
            try context.save()
        } catch {
            print("SaveError")
        }
    }
}

