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
    
    enum duplicateImportAction {
        case ignore
        case cancel
    }

    struct Weak<T: AnyObject> {
        weak var value: T?
    }
    
    private var context: ModelContext
    private var duplicateAction: duplicateImportAction?
    private var cacheBooks: [Weak<Books>] = []
    private var cacheTopics: [Weak<Topics>] = []
    private var cacheAnswers: [Weak<Answers>] = []
    
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
                guard let usuariosImportados = try? decoder.decode([SimpleBookDTO].self, from: restoredData) else {
                    return
                }
                await addItems(usuariosImportados, action: action)
                selectedFile.stopAccessingSecurityScopedResource()
                return
            }
            await addItems(usuariosImportados, action: action)
        }
        selectedFile.stopAccessingSecurityScopedResource()
    }
    
    func processTopicsJSON(desde selectedFile: URL, book: Books, action: @escaping () -> Void) async {
        if selectedFile.startAccessingSecurityScopedResource() {
            guard let restoredData = try? Data(contentsOf: selectedFile) else {
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let usuariosImportados = try? decoder.decode([TopicDTO].self, from: restoredData) else {
                guard let usuariosImportados = try? decoder.decode([SimpleTopicDTO].self, from: restoredData) else {
                    return
                }
                await addItems(usuariosImportados, book: book, action: action)
                selectedFile.stopAccessingSecurityScopedResource()
                return
            }
            await addItems(usuariosImportados, book: book, action: action)
        }
        selectedFile.stopAccessingSecurityScopedResource()
    }
    
    func processAnswersJSON(desde selectedFile: URL, topic: Topics, action: @escaping () -> Void) async {
        if selectedFile.startAccessingSecurityScopedResource() {
            guard let restoredData = try? Data(contentsOf: selectedFile) else {
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let usuariosImportados = try? decoder.decode([AnswerDTO].self, from: restoredData) else {
                guard let usuariosImportados = try? decoder.decode([SimpleAnswerDTO].self, from: restoredData) else {
                    return
                }
                await addItems(usuariosImportados, topic: topic, action: action)
                selectedFile.stopAccessingSecurityScopedResource()
                return
            }
            await addItems(usuariosImportados, topic: topic, action: action)
        }
        selectedFile.stopAccessingSecurityScopedResource()
    }
    
    func JSONToSwiftData(_ item: AnswerDTO, duplicatedOption: Bool = true) -> Answers? {
        let answers: [String] = item.possibleAnswers.map { answer in
            answer.str
        }

        return Answers(id: duplicatedOption ? item.id : UUID(), title: item.title, answers: answers, answer: item.answer, learningLevel: item.learningLevel, dateCreate: item.dateCreate, lastTimeAsked: item.lastTimeAsked, isFavorite: item.isFavorite)
    }
    
    func JSONToSwiftData(_ item: TopicDTO, duplicatedOption: Bool = true) -> Topics? {
        let answers: [Answers] = item.answers.compactMap { answer in
            JSONToSwiftData(answer, duplicatedOption: false)
        }

        return Topics(id: duplicatedOption ? item.id : UUID(), title: item.title, answers: answers, dateCreate: item.dateCreate, lastTimeAsked: item.lastTimeAsked, note: item.note, isFavorite: item.isFavorite)
    }
    
    func JSONToSwiftData(_ item: BookDTO) -> Books? {
        let topics: [Topics] = item.topics.compactMap { topic in
            JSONToSwiftData(topic, duplicatedOption: false)
        }
        if cacheBooks.contains(where: { if let idAux = $0.value{ return idAux.id == item.id }; return false}) {
            if duplicateAction == nil {
                duplicateAction = askUserConfirmation()
            }
            if let action = duplicateAction {
                if case .ignore = action {
                    return Books(id: UUID(), title: item.title, topics: topics, dateCreate: item.dateCreate, lastTimeAsked: item.lastTimeAsked, note: item.note, isFavorite: item.isFavorite)
                } else if case .cancel = action {
                    return nil
                }
            }
        }
        return Books(id: item.id, title: item.title, topics: topics, dateCreate: item.dateCreate, lastTimeAsked: item.lastTimeAsked, note: item.note, isFavorite: item.isFavorite)
    }
    
    func JSONToSwiftData(_ item: SimpleAnswerDTO) -> Answers {
        return Answers(id: UUID(), title: item.title, answers: item.possibleAnswers, answer: item.answer, learningLevel: 20, dateCreate: Date(), lastTimeAsked: Date(), isFavorite: false)
    }
    
    func JSONToSwiftData(_ item: SimpleTopicDTO) -> Topics {
        let answers: [Answers] = item.answers.map { answer in
            JSONToSwiftData(answer)
        }
        return Topics(id: UUID(), title: item.title, answers: answers, dateCreate: Date(), lastTimeAsked: Date(), note: nil, isFavorite: false)
    }
    
    func JSONToSwiftData(_ item: SimpleBookDTO) -> Books {

        let topics: [Topics] = item.topics.map { topic in
            JSONToSwiftData(topic)
        }
        return Books(id: UUID(), title: item.title, topics: topics, dateCreate: Date(), lastTimeAsked: Date(), note: nil, isFavorite: false)
    }
    
    func addItems(_ items: [BookDTO], action: @escaping () -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueBooks", qos: .utility, attributes: .concurrent)
        loadRecordsBooks()
        let numQueue =  min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    if let book = JSONToSwiftData(item) {
                        context.insert(book)
                    }
                }
                action()
            }
        }
        duplicateAction = nil
        DispatchQueue.global().sync {
            do {
                try context.save()
            } catch {
                print("SaveError")
            }
        }
    }
    
    func addItems(_ items: [SimpleBookDTO], action: @escaping () -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueBooks", qos: .utility, attributes: .concurrent)

        let numQueue =  min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    let book = JSONToSwiftData(item)
                    context.insert(book)
                    action()
                }
            }
        }
        DispatchQueue.global().sync {
            do {
                try context.save()
            } catch {
                print("SaveError")
            }
        }
    }
    
    func addItems(_ items: [TopicDTO], book: Books, action: @escaping () -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueTopics", qos: .utility, attributes: .concurrent)
        loadRecordsTopics()
        let numQueue =  min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    if let topic = JSONToSwiftData(item) {
                        context.insert(topic)
                    }
                }
                action()
            }
        }
        duplicateAction = nil
        DispatchQueue.global().sync {
            do {
                try context.save()
            } catch {
                print("SaveError")
            }
        }
    }
    
    func addItems(_ items: [SimpleTopicDTO], book: Books, action: @escaping () -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueTopics", qos: .utility, attributes: .concurrent)

        let numQueue =  min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    let topic = JSONToSwiftData(item)
                    context.insert(topic)
                }
                action()
            }
        }
        DispatchQueue.global().sync {
            do {
                try context.save()
            } catch {
                print("SaveError")
            }
        }
    }
    
    func addItems(_ items: [AnswerDTO], topic: Topics, action: @escaping () -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueAnswer", qos: .utility, attributes: .concurrent)
        loadRecordsAnswers()
        let numQueue = min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    if let answer = JSONToSwiftData(item) {
                        context.insert(answer)
                    }
                }
                action()
            }
        }
        duplicateAction = nil
        DispatchQueue.global().sync {
            do {
                try context.save()
            } catch {
                print("SaveError")
            }
        }
    }
    
    func addItems(_ items: [SimpleAnswerDTO], topic: Topics, action: @escaping () -> Void) async {
        let customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueueAnswer", qos: .utility, attributes: .concurrent)
        
        let numQueue = min(items.count, 10)
        let chuks = divideArray(items, intoChunks: numQueue)
        for i in 0..<numQueue {
            let listAux = chuks[i]
            customConcurrentQueue.sync { [self] in
                for item in listAux {
                    let answer = JSONToSwiftData(item)
                    context.insert(answer)
                }
                action()
            }
        }
        DispatchQueue.global().sync {
            do {
                try context.save()
            } catch {
                print("SaveError")
            }
        }
    }
    
    func loadRecordsBooks() -> Void {
        do {
            let booksAux = try context.fetch(FetchDescriptor<Books>())
            cacheBooks = booksAux.map({ book in
                Weak(value: book)
            })
            
        } catch {}
    }
    func loadRecordsTopics() -> Void {
        do {
            let topicsAux =  try context.fetch(FetchDescriptor<Topics>())
            cacheTopics = topicsAux.map({ topic in
                Weak(value: topic)
            })
        } catch {}
    }
    func loadRecordsAnswers() -> Void {
        do {
            let answersAux = try context.fetch(FetchDescriptor<Answers>())
            cacheAnswers = answersAux.map({ answer in
                Weak(value: answer)
            })
        } catch {}
    }

    func askUserConfirmation() -> duplicateImportAction {
        let semaphore = DispatchSemaphore(value: 0)
        var confirmed: duplicateImportAction?

        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Duplicated", message: "There is data with the same ID, choose an option to finish importing", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Don't import duplicates", style: .default, handler: { _ in
                confirmed = .cancel
                semaphore.signal()
            }))
            
            alert.addAction(UIAlertAction(title: "Assign new ids and keep all data", style: .default, handler: { _ in
                confirmed = .ignore
                semaphore.signal()
            }))
            
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                if let window = windowScene.windows.first {
                    window.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
        semaphore.wait()
        
        return confirmed!
    }
}

