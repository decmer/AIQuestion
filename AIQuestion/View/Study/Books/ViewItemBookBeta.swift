//
//  ViewItemBook.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 13/9/24.
//

import SwiftUI

struct ViewItemsBook: View {
    
    @Binding var isAllEdit: Bool
    @Binding var isEdit: Bool
    @Binding var listSelect: [Books]
    @Binding var books: [Books]
    @Binding var typeOreder: OrederItems
    @State private var searchText: String = ""

    var searchBooks: [Books] {
        if case .title = typeOreder {
            if searchText.isEmpty {
                return books.sorted {
                    $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
            return books.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        } else if case .favorite = typeOreder {
            if searchText.isEmpty {
                return books.sorted {
                    if $0.isFavorite == $1.isFavorite {
                        return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                        }
                    return $0.isFavorite
                }
            }
            return books.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                if $0.isFavorite == $1.isFavorite {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    }
                return $0.isFavorite
            }
        } else {
            if searchText.isEmpty {
                return books.sorted {
                    $0.lastTimeAsked < $1.lastTimeAsked
                }
            }
            return books.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                $0.lastTimeAsked < $1.lastTimeAsked
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 450))]) {
                ForEach(searchBooks, id: \.id) { book in
                    HStack {
                        if isEdit {
                            ZStack {
                                if listSelect.contains(where: { $0.id == book.id }) {
                                    Image(systemName: "circle.fill")
                                        .frame(height: 24)
                                        .tint(Color.blue)
                                } else {
                                    
                                    Image(systemName: "circle")
                                        .frame(height: 24)
                                        .tint(Color.blue)
                                }
                            }
                            .padding(5)
                        }
                        NavigationLink(destination: MainViewTopics(book: book)) {
                            ItemView(book: book)
                        }
                        .disabled(isEdit)
                        .onTapGesture {
                            if isEdit {
                                if listSelect.contains(where: { $0.id == book.id }) {
                                    listSelect.removeAll { $0.id == book.id }
                                } else {
                                    listSelect.append(book)
                                }
                            }
                        }
                        
                    }
                    
                    .padding(.horizontal, 20)
                    .visualEffect { content, proxy in
                        let frame = proxy.frame(in: .scrollView(axis: .vertical))
                        
                        let distance = min(0, frame.minY)
                        return content
                            .hueRotation(.degrees(frame.origin.y / 10))
                            .scaleEffect(1 + distance / 700)
                            .offset(y: -distance / 1.25)
                            .brightness(-distance / 400)
                            .blur(radius: -distance / 50)
                    }
                }
            }
            
            .searchable(text: $searchText)
        }
    }
    
    struct ItemView: View {
        @State var isEditItem = false
        var book: Books

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.itemsColors)
                HStack {
                    VStack {
                        HStack {
                            Text("\(book.title)")
                                .foregroundStyle(Color.primary)
                                .font(.title)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        if let note = book.note {
                            HStack {
                                Text("\(note)")
                                    .font(.footnote)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    Spacer()
                    VStack {
                        if book.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.yellow)
                                .padding(20)
                        }
                    }
                }
            }
            .contextMenu {
                Button {
                    withAnimation {
                        book.isFavorite.toggle()
                    }
                } label: {
                    Text("Favorite")
                    Image(systemName: "star.fill")
                }
                Button {
                    isEditItem = true
                } label: {
                    Text("Edit")
                    Image(systemName: "pencil")
                }
            }
            .sheet(isPresented: $isEditItem) {
                ViewCreateBook(isPresent: $isEditItem, book: book)
            }
            .frame(height: 100)
        }
    }
}
