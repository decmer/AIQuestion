//
//  ViewBook.swift
//  AIQuestion
//
//  Created by Jose Merino Decena on 15/9/24.
//

import SwiftUI
import _SwiftData_SwiftUI

struct ViewListAnswer: View {
    @Environment(ViewModel.self) var vm

    @State var topic: Topics
    @State var answers: [Answers]
    @State private var isCreate: Bool
    @State private var isEdit: Bool
    @State private var searchText: String
    @State private var selected: [Answers]
    @State private var showAlert: Bool
    @State var showNotificate: Bool
    @State var titleNotificate: String
    @State var messageNotificate: String
    @State private var isAllEdit: Bool
    @State private var showImporter: Bool
    @State private var showExporter: Bool
    @State private var exportURL: URL?
    @State private var isPlay: Bool
    @State var typeOreder: OrederItems
    
    var searchBooks: [Answers] {
        if case .title = typeOreder {
            if searchText.isEmpty {
                return answers.sorted {
                    $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
            return answers.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        } else if case .favorite = typeOreder {
            if searchText.isEmpty {
                return answers.sorted {
                    if $0.isFavorite == $1.isFavorite {
                        return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                        }
                    return $0.isFavorite
                }
            }
            return answers.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                if $0.isFavorite == $1.isFavorite {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    }
                return $0.isFavorite
            }
        } else {
            if searchText.isEmpty {
                return answers.sorted {
                    $0.lastTimeAsked < $1.lastTimeAsked
                }
            }
            return answers.filter { topic in
                topic.title.contains(searchText)
            }.sorted {
                $0.lastTimeAsked < $1.lastTimeAsked
            }
        }
    }
    
    init(topic: Topics) {
        self.topic = topic
        self.answers = []
        self.isCreate = false
        self.isEdit = false
        self.searchText = ""
        self.selected = []
        self.showAlert = false
        self.showNotificate = false
        self.titleNotificate = ""
        self.messageNotificate = ""
        self.isAllEdit = false
        self.showImporter = false
        self.showExporter = false
        self.isPlay = false
        self.typeOreder = .title
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    items()
                }
            }
            .navigationTitle(topic.title)
            .toolbar(content: {
                NavigationButtonsList<Answers>(isCreate: $isCreate, isEdit: $isEdit, selected: $selected, showAlert: $showAlert, isAllEdit: $isAllEdit, showImporter: $showImporter, showExporter: $showExporter, exportURL: $exportURL, items: $answers, isPlay: $isPlay, showNotificate: $showNotificate, titleNotificate: $titleNotificate, messageNotificate: $messageNotificate, exportJSON: exportJSON)
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
                    answers = vm.fetchAll(topic: topic)
                    isEdit = false
                }
            }
        } message: {
            Text("If you delete it they remain in the trash for 30 days, then they will be permanently deleted")
        }
        .sheet(isPresented: $isCreate) {
            ViewCreateAnswer(isPresent: $isCreate, topic: topic) {
                answers = vm.fetchAll(topic: topic)
            }
        }
        .fullScreenCover(isPresented: $isPlay, content: {
            ViewPlay(isPlay: $isPlay, answers: answers)
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
                        await vm.processImportJSON.processAnswerdsJSON(desde: url, topic: topic) { answer in
                            vm.addItem(item: answer, topic: topic)
                            answers = vm.fetchAll(topic: topic)
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
                answers = vm.fetchAll(topic: topic)
            }
    }
    
    private func items() -> some View {
        ForEach(searchBooks) { answer in
            ViewItemAnswer(isAllEdit: $isAllEdit, isEdit: $isEdit, listSelect: $selected, answer: answer)
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
            let jsonData = try encoder.encode(vm.processExportJSON.transformAnswersJSON(answers: selected))
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("AnswerEsported-\(Date().timeIntervalSince1970).json")
            
            try jsonData.write(to: tempURL)
            exportURL = tempURL
        } catch {
            print("Error al codificar o escribir el archivo JSON: \(error)")
        }
    }
}
