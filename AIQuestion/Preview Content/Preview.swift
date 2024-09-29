//
//  Preview.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 12/9/24.
/// sqlite3: usuarios/jose/Library/Developer/Xcode/UserData/Previews/SimulatorDevices/195C740C-E3DD-4FC5-AB33-3D9FB2E5DEE3/data/Containers/Data/Application/88022DB1-C4C8-41B3-A88C-46EDEF9DBAB2/Library/ApplicationSupport/default.store

import Foundation
import SwiftUI
import SwiftData

extension Books {
    static var preview = Books("Preview")
}

extension Topics {
    static var preview = Topics("Tema Preview")
}

extension Answers {
    static var preview = Answers("Que es una preview", answers: ["a) una vista en tiempo de compilacion", "b) Una vista en tiempo de ejecicion", "c) Un framework", "d) Ninguna de ñas anteriores"], answer: 0)
}

extension ModelContainer {
    static var preview = {
        print("Hola")
        let schema = Schema([
            
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            if let url = container.configurations.first?.url.path(percentEncoded: false) {
                print("sqlite3 \"\(url)\"")
            } else {
                print("No SQLite database found.")
            }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }
}

extension ModelContext {
    static var preview = {
        print("hola")
        let context = ModelContext(.preview())
        print(context.sqliteCommand)
        context.insert(Books.preview)
        Books.preview.topics.append(.preview)
        Topics.preview.answers.append(.preview)
        return context
    }
}

extension ViewModel {
    static var preview = ViewModel(context: .preview())
}

extension Bool {
    @State static var previewTrue = true
    @State static var previewFalse = false
}

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
