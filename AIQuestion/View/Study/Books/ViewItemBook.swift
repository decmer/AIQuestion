//
//  ViewItemBook.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 13/9/24.
//

import SwiftUI

struct ViewItemBook: View {
    @Environment(ViewModel.self) private var vm
    
    @Binding var isAllEdit: Bool
    @Binding var isEdit: Bool
    @Binding var listSelect: [Books]
    @State var isSelected = false
    var book: Books
    
    var body: some View {
        ZStack {
            if isEdit {
                HStack {
                    Button {
                        withAnimation(.easeOut(duration: 0.4)) {
                            isSelected.toggle()
                            if isSelected {
                                listSelect.append(book)
                            } else {
                                listSelect.removeAll(where: { $0.id == book.id })
                            }
                        }
                    } label: {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .frame(height: 24)
                                .tint(Color.blue)
                                .opacity(isSelected ? 1 : 0)
                            Image(systemName: "circle")
                                .frame(height: 24)
                                .tint(Color.blue)
                                .opacity(isSelected ? 0 : 1)
                        }
                    }
                    .padding(5)
                    .transition(.scale(scale: 2))
                    Spacer()
                }
            }
            ZStack {
                NavigationLink(destination: ViewListTopics(book: book)) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.itemsColors)
                }
                .disabled(isEdit)
                .onTapGesture {
                    if isEdit {
                        withAnimation(.easeOut(duration: 0.4)) {
                            isSelected.toggle()
                            if isSelected {
                                listSelect.append(book)
                            } else {
                                listSelect.removeAll(where: { $0.id == book.id })
                            }
                        }
                    }
                }
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
                } label:{
                    Image(systemName: "star.fill")
                }
            }
            .frame(height: 100)
            .padding(.leading, isEdit ? 40 : 0)
            .animation(.easeInOut(duration: 0.3), value: isEdit)
        }
        .onAppear {
            if isAllEdit {
                isSelected = true
            }
        }
        .onChange(of: isAllEdit) { oldValue, newValue in
            isSelected = newValue
        }
        .onChange(of: isEdit) { oldValue, newValue in
            if !newValue {
                isSelected = newValue
            }
        }
    }
}
