//
//  IAQuestionApp.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 12/9/24.
//

import SwiftUI
import SwiftData

@main
struct IAQuestionApp: App {
    var sharedModelContainer: ModelContainer

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .environment(ViewModel(context: sharedModelContainer.mainContext))
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        let schema = Schema([
            Books.self,
            Topics.self,
            Answers.self,
            StrAnswer.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }
}
