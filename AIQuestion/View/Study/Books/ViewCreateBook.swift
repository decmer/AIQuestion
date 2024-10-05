//
//  ViewCreateBook.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 13/9/24.
//

import SwiftUI

struct ViewCreateBook: View {
    @Environment(ViewModel.self) var vm
    
    @Binding var isPresent: Bool
    @State var title: String
    @State var note: String
    var book: Books?
    private let characterTitleLimit: Int = 30
    private let characterNoteLimit: Int = 50
    
    var action: () -> Void
    
    init(isPresent: Binding<Bool>, title: String = "", note: String = "", book: Books? = nil, action: @escaping () -> Void = {}) {
        self._isPresent = isPresent
        if let book = book {
            self.book = book
            self.title = book.title
            self.note = book.note ?? ""
        } else {
            self.title = title
            self.note = note
            self.book = book
            
        }
        self.action = action
    }
    
    var body: some View {
        NavigationStack {
            Form{
                Section("Info") {
                    TextField("Title", text: $title)
                        .multilineTextAlignment(.leading)
                    TextField("Note", text: $note)
                        .multilineTextAlignment(.leading)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if let book = book {
                        Button("Save") {
                            book.title = title
                            book.note = note.isEmpty ? nil : note
                            isPresent = false
                        }
                    } else {
                        Button("Create") {
                            vm.addItem(item: Books(title, note: note.isEmpty ? nil : note))
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
            .navigationTitle("Crate Book")
        }
    }
}


