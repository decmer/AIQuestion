//
//  ComponentsText.swift
//  AIQuestion
//
//  Created by Jose Decena on 27/9/24.
//

import SwiftUI

struct TextLimit: View {
    
    @Binding var text: String
    let placeholder: String?
    let limit: Int
    
    var body: some View {
        HStack {
            TextField(placeholder ?? "", text: $text)
                .onChange(of: text) { oldValue, newValue in
                    if newValue.count > limit {
                        text = oldValue
                    }
                }
            Text("\(limit - text.count)")
        }
    }
}

struct NavigationButtonsList<Item>: ToolbarContent {
    @Environment(ViewModel.self) private var vm
    
    @Binding var isCreate: Bool
    @Binding var isEdit: Bool
    @Binding var selected: [Item]
    @Binding var showAlert: Bool
    @Binding var isAllEdit: Bool
    @Binding var showImporter: Bool
    @Binding var showExporter: Bool
    @Binding var exportURL: URL?
    @Binding var items: [Item]
    @Binding var isPlay: Bool
    @Binding var showNotificate: Bool
    @Binding var titleNotificate: String
    @Binding var messageNotificate: String
    var exportJSON: () async -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                if (isEdit) {
                    Task {
                        await exportJSON()
                    }
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .symbolEffect(.disappear.down.byLayer, isActive: !isEdit)
            }
            .frame(width: 35)
        }

        ToolbarItem(placement: .automatic) {
            Button {
                if isEdit {
                    withAnimation {
                        isAllEdit.toggle()
                        if isAllEdit {
                            selected = items
                        } else {
                            selected.removeAll()
                        }
                    }
                } else {
                    if vm.answerdLogic.isEmpty(items: items) {
                        withAnimation {
                            showNotificate = true
                            titleNotificate = "No Questions Asked"
                            messageNotificate = "There are not enough questions to play, please create more"
                        }
                    } else {
                        isPlay = true
                    }
                }
            } label: {
                Image(systemName: isEdit ? "square.stack.3d.down.right.fill" : "play")
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer)))
            }
            .frame(width: 35)
        }
        
        ToolbarItem(placement: .automatic) {
            Button {
                if isEdit {
                    if !selected.isEmpty {
                        showAlert = true
                    }
                } else {
                    isCreate = true
                }
            } label: {
                Image(systemName: isEdit ? "trash.fill" : "plus")
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer)))
                    .tint(isEdit ? .red : .green)
                
            }
            .frame(width: 35)
            .contextMenu {
                if !isEdit {
                    Button(action: {
                        showImporter = true
                    }) {
                        Label("Import", systemImage: "tray.and.arrow.down")
                    }
                }
            }
        }
        
        ToolbarItem(placement: .automatic) {
            Button {
                withAnimation {
                    isEdit.toggle()
                }
                isAllEdit = false
                selected.removeAll()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .frame(width: 35)
        }
    }
}

enum OrederItems: String, CaseIterable, Identifiable {
    case title
    case favorite
    case ask
    
    var id: String { self.rawValue }
}


struct OverlayModifier: ViewModifier {

    @Binding var order: OrederItems
    @State var isMenuOpen: Bool = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                HStack {
                    orderOverlay()
                    Spacer()
                }
            }
        }
    }
    
    private func orderOverlay() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.colorMenuOrder.opacity(0.8))
                .frame(maxWidth: isMenuOpen ? .infinity : 40)
                .frame(height: 40)
                .animation(.easeInOut(duration: 0.5), value: isMenuOpen)

            HStack {
                Image(systemName: "arrow.up.arrow.down")
                    .padding(isMenuOpen ? 8.5 : 0)
                    .foregroundStyle(Color.black.opacity(0.9))
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }
                if isMenuOpen {
                    selectOptionMenu()
                }
            }
        }
        .padding(.horizontal, 50)
        .padding(.bottom, 15)
    }
    
    private func selectOptionMenu() -> some View {
        HStack {
            ForEach(OrederItems.allCases) { item in
                Button {
                    order = item
                } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .frame(height: 34)
                                .tint(item == order ? Color.gray : Color.clear)
                                
                            Text(item.rawValue.capitalized)
                                .font(.footnote)
                                .foregroundStyle(item == order ? Color.white : Color.black)
                                .padding(.horizontal, 1)
                        }
                        .padding(.horizontal, 3)
                }
            }
        }
    }

}

extension View {
    func orderMenu(_ order: Binding<OrederItems>) -> some View {
        self.modifier(OverlayModifier(order: order))
    }
}

struct CustomAlert: View {
    @Binding var showAlert: Bool
    @Binding var title: String
    @Binding var message: String

    var body: some View {
        if showAlert {
            VStack(spacing: 16) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white)

                Button(action: {
                    withAnimation {
                        showAlert.toggle()
                    }
                }) {
                    Text("OK")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
            .shadow(radius: 20)
            .frame(width: 300)
            .transition(.scale)
            .animation(.easeInOut, value: showAlert)
        }
    }
}

struct ContentView: View {
    @State private var showAlert = false

    var body: some View {
        VStack {
            Button("Mostrar Alerta") {
                withAnimation {
                    showAlert.toggle()
                }
            }
        }
    }
}

struct OverlayCounter: ViewModifier {

    @Binding var isPresent: Bool
    @Binding var nCorrect: Int
    @Binding var nIncorrect: Int
    @State var isShow = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isShow {
                VStack {
                    HStack {
                        Spacer()
                        getBody()
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    isPresent.toggle()
                                }
                            }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4, execute: {
                withAnimation {
                    isShow = true
                }
            })
        }
    }

    private func getBody() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 19)
                .foregroundStyle(Color.black)
                .frame(width: 126, height: isPresent ? 90 : 37)
                .padding(.top, 14)
                .overlay {
                    ZStack {
                        VStack {
                            Spacer()
                            HStack {
                                Text("\(nCorrect)")
                                    .padding(.leading, 10)
                                    .foregroundStyle(Color.green)
                                Spacer()
                                Text("\(nIncorrect)")
                                    .padding(.trailing, 10)
                                    .foregroundStyle(Color.red)
                            }
                            Spacer()
                        }
                        .padding(.top, 14)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Time")
                                    .padding(10)
                                    .foregroundStyle(Color.white)
                                Spacer()
                            }
                        }
                        .padding(.top, 14)
                    }
                }
        }
        .ignoresSafeArea()
    }
    
}

extension View {
    func counterOverlay(_ isPresent: Binding<Bool>, nCorrect: Binding<Int>, nIncorrect: Binding<Int>) -> some View {
        self.modifier(OverlayCounter(isPresent: isPresent, nCorrect: nCorrect, nIncorrect: nIncorrect))
    }
}

#Preview {

    @Previewable @State var isPresent: Bool = true
    @Previewable @State var nCorrect: Int = 900
    @Previewable @State var nIncorrect: Int = 990
    @Previewable @State var count: Int = 0
    
    Button(action: {
        isPresent.toggle()
    }, label: {
        Text("Button")
            
    })
    .counterOverlay($isPresent, nCorrect: $nCorrect, nIncorrect: $nIncorrect)
}
