//
//  ViewBook.swift
//  AIQuestion
//
//  Created by Jose Merino Decena on 15/9/24.
//

import SwiftUI
import _SwiftData_SwiftUI

struct ViewListTopics: View {
    @Environment(ViewModel.self) private var vm
    
    @State var book: Books
    @State var topics: [Topics] = []
    @State private var isCreate: Bool = false
    @State private var isEdit: Bool = false
    @State private var searchText: String = ""
    @State private var selected: [Topics] = []
    @State private var showAlert: Bool = false
    @State var showNotificate: Bool = false
    @State var titleNotificate: String = ""
    @State var messageNotificate: String = ""
    @State private var isAllEdit: Bool = false
    @State private var showImporter: Bool = false
    @State private var showExporter: Bool = false
    @State private var exportURL: URL?
    @State private var isPlay: Bool = false
    @State var typeOreder: OrederItems = .title
    
    var searchBooks: [Topics] {
        if case .title = typeOreder {
            if searchText.isEmpty {
                return topics.sorted {
                    $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
            return topics.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        } else if case .favorite = typeOreder {
            if searchText.isEmpty {
                return topics.sorted {
                    if $0.isFavorite == $1.isFavorite {
                        return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                        }
                    return $0.isFavorite
                }
            }
            return topics.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                if $0.isFavorite == $1.isFavorite {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    }
                return $0.isFavorite
            }
        } else {
            if searchText.isEmpty {
                return topics.sorted {
                    $0.lastTimeAsked < $1.lastTimeAsked
                }
            }
            return topics.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                $0.lastTimeAsked < $1.lastTimeAsked
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    items()
                }
            }
            .navigationTitle(book.title)
            .toolbar(content: {
                NavigationButtonsList<Topics>(isCreate: $isCreate, isEdit: $isEdit, selected: $selected, showAlert: $showAlert, isAllEdit: $isAllEdit, showImporter: $showImporter, showExporter: $showExporter, exportURL: $exportURL, items: $topics, isPlay: $isPlay, showNotificate: $showNotificate, titleNotificate: $titleNotificate, messageNotificate: $messageNotificate, exportJSON: exportJSON)
            })
            .searchable(text: $searchText)
        }
        .overlay(
            CustomAlert(showAlert: $showNotificate, title: $titleNotificate, message: $messageNotificate)
        )
        .orderMenu($typeOreder)
        .alert("¡Are you sure you want to delete these books!", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await vm.deleteAll(selected)
                    topics = vm.fetchAll(book: book)
                    isEdit = false
                }
            }
        } message: {
            Text("If you delete it they remain in the trash for 30 days, then they will be permanently deleted")
        }
        .sheet(isPresented: $isCreate) {
            ViewCreateTopic(isPresent: $isCreate, book: book) {
                topics = vm.fetchAll(book: book)
            }
        }
        .fullScreenCover(isPresented: $isPlay, content: {
            ViewPlay(isPlay: $isPlay, book: book)
        })
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { resultado in
            switch resultado {
            case .success(let urls):
                if let url = urls.first {
                    Task {
                        await vm.processImportJSON.processTopicsJSON(desde: url, book: book) { topic in
                            vm.addItem(item: topic, book: book)
                            topics = vm.fetchAll(book: book)
                        }
                    }
                }
            case .failure(let error):
                print("Error al seleccionar el archivo: \(error.localizedDescription)")
            }
        }
        .fileExporter(
            isPresented: Binding<Bool>(
                get: { exportURL != nil },
                set: { if !$0 { exportURL = nil } }
            ),
            document: exportURL != nil ? JSONFile(url: exportURL!) : nil,
            contentType: .json) { result in
                    switch result {
                        case .success:
                            print("Archivo exportado correctamente.")
                        case .failure(let error):
                            print("Error al exportar: \(error.localizedDescription)")
                    }
                }
            .onAppear {
                topics = vm.fetchAll(book: book)
            }
    }
    
    private func items() -> some View {
        ForEach(searchBooks) { top in
            ViewItemTopic(isAllEdit: $isAllEdit, isEdit: $isEdit, listSelect: $selected, topic: top)
                .padding(.horizontal, 20)
                .visualEffect { content, proxy in
                    let frame = proxy.frame(in: .scrollView(axis: .vertical))
                    
                    let distance = min(0, frame.minY)
                    
                    return content
                        .hueRotation(.degrees(frame.origin.y / 10))
                        .scaleEffect(1 + distance / 700)
                        .offset(y: frame.minY > -250 ? -distance / 1.25 : -100)
                        .brightness(-distance / 400)
                        .blur(radius: -distance / 50)
                }
        }
    }
    
    func exportJSON() async {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(vm.processExportJSON.transformTopicsJSON(topics: selected))
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("TopicsEsported-\(Date().timeIntervalSince1970).json")
            
            try jsonData.write(to: tempURL)
            exportURL = tempURL
        } catch {
            print("Error al codificar o escribir el archivo JSON: \(error)")
        }
    }
}
