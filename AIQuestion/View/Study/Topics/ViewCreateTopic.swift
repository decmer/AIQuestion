//
//  ViewCreateBook.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 13/9/24.
//

import SwiftUI

struct ViewCreateTopic: View {
    @Environment(ViewModel.self) var vm
    
    @Binding var isPresent: Bool
    @State var title: String
    @State var note: String
    let book: Books
    var topic: Topics?
    
    var action: () -> Void
    
    init(isPresent: Binding<Bool>, book: Books, action: @escaping () -> Void) {
        self._isPresent = isPresent
        self.title = ""
        self.note = ""
        self.book = book
        self.action = action
    }
    
    init(isPresent: Binding<Bool>, topic: Topics) {
        self._isPresent = isPresent
        self.topic = topic
        self.title = topic.title
        self.note = topic.note ?? ""
        self.book = topic.book!
        self.action = {}
    }
    
    var body: some View {
        NavigationStack {
            Form{
                Section("Info") {
                    TextField("Title", text: $title)
                    TextField("Note", text: $note)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if let topic = topic {
                        Button("Save") {
                            topic.title = title
                            topic.note = note.isEmpty ? nil : note
                            isPresent = false
                        }
                    } else {
                        Button("Create") {
                            let topics = Topics(title, note: note.isEmpty ? nil : note)
                            vm.addItem(item: topics, book: book)
                            action()
                            isPresent = false
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        isPresent = false
                    }
                }
            }
            .navigationTitle("Crate Topics")
        }
    }
}
