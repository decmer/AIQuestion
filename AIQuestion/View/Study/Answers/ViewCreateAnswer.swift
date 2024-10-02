//
//  ViewCreateBook.swift
//  IAQuestion
//
//  Created by Jose Merino Decena on 13/9/24.
//

import SwiftUI

struct ViewCreateAnswer: View {
    @Environment(ViewModel.self) var vm
    
    @Binding var isPresent: Bool
    @State var title: String
    @State var answers: [String]
    @State var solution: Int
    @State var nAnswers: Int
    let topic: Topics
    var answer: Answers?
    private let characterLimit: Int = 25
    
    var action: () -> Void
    
    init(isPresent: Binding<Bool>, topic: Topics, action: @escaping () -> Void) {
        self._isPresent = isPresent
        self.title = ""
        self.answers = [String]()
        self.solution = 0
        self.nAnswers = 4
        self.topic = topic
        self.action = action
    }
    
    init (isPresent: Binding<Bool>, answer: Answers) {
        let answers: [String] = answer.answers!.map { answer in
            answer.str
        }
        self.answer = answer
        self._isPresent = isPresent
        self.title = answer.title
        self.answers = answers
        self.solution = answer.answer
        self.nAnswers = answer.answers!.count
        self.topic = answer.topic!
        self.action = {}
    }
    
    var body: some View {
        NavigationStack {
            Form{
                Section("Info") {
                    TextField("Title", text: $title)
                        .onChange(of: title) { oldValue, newValue in
                            if newValue.count > characterLimit {
                                title = oldValue
                            }
                        }
                    
                    Stepper(value: $nAnswers, in: 2...10) {
                        Text("Numbers of answers: \(nAnswers)")
                    }
                    .onChange(of: nAnswers) {
                        ajustarRespuestas()
                    }
                }
                Section("Ask") {
                    Picker(selection: $solution, label: Text("Answer")) {
                        ForEach(0..<answers.count, id: \.self) { i in
                            Text("\(Character(UnicodeScalar(97+i)!))) \(answers[i].prefix(15))\(answers[i].count > 15 ? "..." : "")")
                        }
                    }
                
                    ForEach(0..<answers.count, id: \.self) { num in
                        TextField("\(Character(UnicodeScalar(97+num)!)))", text: $answers[num])
                    }
                }
            }
            .onAppear {
                ajustarRespuestas()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if let answer = answer {
                        Button("Save") {
                            let answers: [StrAnswer] = answers.map { str in
                                StrAnswer(str: str)
                            }
                            answer.title = title
                            answer.answer = solution
                            answer.answers = answers
                            isPresent = false
                        }
                    } else {
                        Button("Create") {
                            let newAnswer = Answers(title, answers: answers, answer: solution)
                            vm.addItem(item: newAnswer, topic: topic)
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
            .navigationTitle("Crate Topics")
        }
    }
    
    private func ajustarRespuestas() {
        if nAnswers > answers.count {
            answers.append(contentsOf: Array(repeating: "", count: nAnswers - answers.count))
        } else if nAnswers < answers.count {
            answers.removeLast(answers.count - nAnswers)
        }
    }
}
