//
//  ViewModel.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 12/9/24.
//

import Foundation
import SwiftData

@Observable
final class ViewModel {
    private var context: ModelContext
    let processImportJSON: ProcessImportJSON
    let processExportJSON: ProcessExportJSON
    let answerdLogic: RandomQuestLogic
    
    var books: [Books] = []
    
    init(context: ModelContext) {
        self.context = context
        self.processImportJSON = ProcessImportJSON(context: context)
        self.processExportJSON = ProcessExportJSON()
        self.answerdLogic = RandomQuestLogic()
        fetchAll()
    }
    
    func fetchAll() {
        let descriptor = FetchDescriptor<Books>()
        do {
            books = try context.fetch(descriptor)
        } catch {
            print("Error in fetch")
        }
    }
    
    func addItem(item: Books) {
        context.insert(item)
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
        fetchAll()
    }
    
    func addItem(item: Topics, book: Books) {
        book.topics.append(item)
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func addItem(item: Answers, topic: Topics) {
        topic.answers.append(item)
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func deleteAll(_ items: [Books]) {
        for item in items {
            context.delete(item)
            fetchAll()
        }
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func deleteAll(_ items: [Topics]) {
        for item in items {
            delete(item)
        }
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func delete(_ item: Topics) {
        if let book = item.book {
            book.topics.removeAll { topic in
                topic.id == item.id
            }
        }
    }
    
    func deleteAll(_ items: [Answers]) {
        for item in items {
            delete(item)
        }
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func delete(_ item: Answers) {
        if let topic = item.topic {
            topic.answers.removeAll { answer in
                answer == item
            }
        }
    }
    
    func setFavorite(_ item: Books) {
        let itemId = item.id
        let descriptor = FetchDescriptor<Books>(predicate: #Predicate { itemAux in
            itemAux.id == itemId
        })
        do {
            let search = try context.fetch(descriptor)
            for book in search {
                book.isFavorite.toggle()
            }
        } catch {
            // Manejo del error
        }
    }
}
