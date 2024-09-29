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
    @State var title = ""
    @State var note = ""
    let book: Books
    
    var action: (Topics) -> Void
    
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
                    Button("Create") {
                        let topics = Topics(title, note: note.isEmpty ? nil : note)
                        vm.addItem(item: topics, book: book)
                        action(topics)
                        isPresent = false
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
