//
//  ViewListBooks2.swift
//  AIQuestion
//
//  Created by Jose Decena on 3/10/24.
//

import SwiftUI
import SwiftData

@MainActor
struct MainViewTopics: View {
    @Environment(ViewModel.self) private var vm
    
    @State var book: Books
    @State private var topics = [Topics]()
    @State private var isCreate = false
    @State private var isEdit = false
    @State private var searchText: String = ""
    @State private var selected = [Topics]()
    @State private var showAlert = false
    @State var showNotificate: Bool = false
    @State var titleNotificate: String = ""
    @State var messageNotificate: String = ""
    @State private var isAllEdit = false
    @State private var showImporter = false
    @State private var showExporter = false
    @State private var exportURL: URL?
    @State private var isPlay: Bool = false
    @State var typeOreder: OrederItems = .title
    
    var body: some View {
        NavigationStack {
            ViewItemTopic(isAllEdit: $isAllEdit, isEdit: $isEdit, listSelect: $selected, topics: $topics, typeOreder: $typeOreder)
                .navigationTitle("\(book.title)")
                .toolbar(content: {
                    NavigationButtonsList<Topics>(isCreate: $isCreate, isEdit: $isEdit, selected: $selected, showAlert: $showAlert, isAllEdit: $isAllEdit, showImporter: $showImporter, showExporter: $showExporter, exportURL: $exportURL, items: $topics, isPlay: $isPlay, showNotificate: $showNotificate, titleNotificate: $titleNotificate, messageNotificate: $messageNotificate, exportJSON: exportJSON)
                })
            
        }
        .overlay(
            CustomAlert(showAlert: $showNotificate, title: $titleNotificate, message: $messageNotificate)
        )
        .orderMenu($typeOreder)
        .alert("¡Are you sure you want to delete these books!", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                let seelectDelete = selected
                Task {
                    await vm.deleteAll(seelectDelete)
                    topics = vm.fetchAll(book: book)
                }
                isEdit = false
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
                        await vm.processImportJSON.processTopicsJSON(desde: url, book: book) {
                            withAnimation {
                                topics = vm.fetchAll(book: book)
                            }
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
                withAnimation {
                    topics = vm.fetchAll(book: book)
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
                .appendingPathComponent("BooksEsported-\(Date().timeIntervalSince1970).json")
            
            try jsonData.write(to: tempURL)
            exportURL = tempURL
        } catch {
            print("Error al codificar o escribir el archivo JSON: \(error)")
        }
    }
}
