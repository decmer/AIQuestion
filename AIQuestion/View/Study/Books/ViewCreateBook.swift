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
    @State var title = ""
    @State var note = ""
    private let characterTitleLimit: Int = 30
    private let characterNoteLimit: Int = 50
    
    var body: some View {
        NavigationStack {
            Form{
                Section("Info") {
                    TextLimit(text: $title,placeholder: "Title", limit: characterTitleLimit)
                    TextLimit(text: $note,placeholder: "Note", limit: characterNoteLimit)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        vm.addItem(item: Books(title, note: note.isEmpty ? nil : note))
                        isPresent = false
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


