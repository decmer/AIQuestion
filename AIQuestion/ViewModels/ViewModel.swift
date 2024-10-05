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
    
    init(context: ModelContext) {
        self.context = context
        self.processImportJSON = ProcessImportJSON(context: context)
        self.processExportJSON = ProcessExportJSON()
        self.answerdLogic = RandomQuestLogic()
    }
    
    func fetchAll() -> [Books] {
        let descriptor = FetchDescriptor<Books>()
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error in fetch")
        }
        return []
    }
    
    func fetchAll(book: Books) -> [Topics] {
        let id = book.id
        let descriptor = FetchDescriptor<Topics>(predicate: #Predicate { item in
            item.book?.id == id
        })
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error in fetch")
        }
        return []
    }
    
    func fetchAll(topic: Topics) -> [Answers] {
        let id = topic.id
        let descriptor = FetchDescriptor<Answers>(predicate: #Predicate { item in
            item.topic?.id == id
        })
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error in fetch")
        }
        return []
    }
    
    func fetch(book: Books) -> [Books] {
        let id = book.id
        let descriptor = FetchDescriptor<Books>(predicate: #Predicate { item in
            item.id == id
        })
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error in fetch")
        }
        return []
    }
    
    func addItem(item: Books) {
        context.insert(item)
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func addItem(item: Topics, book: Books) {
        if book.topics != nil {
            book.topics!.append(item)
        } else {
            print("Error in addItem")
        }
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func addItem(item: Answers, topic: Topics) {
        if topic.answers != nil {
            topic.answers!.append(item)
        } else {
            print("Error in addItem")
        }
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func deleteAll(_ items: [Books]) async {
        for item in items {
            context.delete(item)
        }
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func deleteAll(_ items: [Topics]) async {
        for item in items {
            context.delete(item)
        }
        do {
            try context.save()
        } catch {
            print("Error in save")
        }
    }
    
    func deleteAll(_ items: [Answers]) async {
        for item in items {
            context.delete(item)
        }
        do {
            try context.save()
        } catch {
            print("Error in save")
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
