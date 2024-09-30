//
//  ViewBook.swift
//  AIQuestion
//
//  Created by Jose Merino Decena on 15/9/24.
//

import SwiftUI
import _SwiftData_SwiftUI

struct ViewListAnswer: View {
    @Environment(ViewModel.self) private var vm

    @State var topic: Topics
    @State var answers: [Answers]
    @State private var isCreate = false
    @State private var isEdit = false
    @State private var searchText: String = ""
    @State private var selected = [Answers]()
    @State private var showAlert = false
    @State private var isAllEdit = false
    @State private var showImporter = false
    @State private var showExporter = false
    @State private var exportURL: URL?
    @State private var isPlay: Bool = false
    @State var typeOreder: OrederItems = .title
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 350, maximum: 450))]) {
                    items()
                }
            }
            .navigationTitle(topic.title)
            .toolbar(content: {
                NavigationButtonsList<Answers>(isCreate: $isCreate, isEdit: $isEdit, selected: $selected, showAlert: $showAlert, isAllEdit: $isAllEdit, showImporter: $showImporter, showExporter: $showExporter, exportURL: $exportURL, items: $answers, isPlay: $isPlay, exportJSON: exportJSON)
            })
            .searchable(text: $searchText)
        }
        .orderMenu($typeOreder)
        .alert("¡Are you sure you want to delete these books!", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                vm.deleteAll(selected)
                if let ans = topic.answers {
                    answers = ans
                }
                isEdit = false
            }
        } message: {
            Text("If you delete it they remain in the trash for 30 days, then they will be permanently deleted")
        }
        .sheet(isPresented: $isCreate) {
            ViewCreateAnswer(isPresent: $isCreate, topic: topic) {
                answers.append($0)
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
                            answers.append(answer)
                            if let ans = topic.answers {
                                answers = ans
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
                        .offset(y: -distance / 1.25)
                        .brightness(-distance / 400)
                        .blur(radius: -distance / 50)
                }
                .transition(.move(edge: .leading))
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
