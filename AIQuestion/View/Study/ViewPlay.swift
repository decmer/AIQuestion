//
//  ViewPlay.swift
//  AIQuestion
//
//  Created by Jose Decena on 25/9/24.
//

import SwiftUI

struct ViewPlay: View {
    @Environment(ViewModel.self) private var vm
    
    @Binding var isPlay: Bool
    @State var assigningQuestions = true
    @State var answer: Answers?
    @State var answers: [Answers]?
    @State var isAnswered: Bool = false
    @State var isRevised: Bool = true

    var book: Books?
    var books: [Books]?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isRevised {
                    revisedAnswers
                        .padding(.horizontal, 37)
                        .padding(.vertical, 10)
                        .frame(height: 160)
                }
                Spacer()
                if answers != nil, let answer = answer {
                    ask(answer: answer)
                        
                    Spacer()
                    if isAnswered {
                        HStack {
                            Spacer()
                            Button {
                                self.answer = vm.answerdLogic.nextQuestion()
                                withAnimation {
                                    isAnswered = false
                                }
                                if let answer = self.answer, let answers = answer.answers {
                                    if (answer.answer >= answers.count) {
                                        withAnimation {
                                            isRevised = true
                                            isAnswered = true
                                        }
                                    } else {
                                        withAnimation {
                                            isRevised = false
                                        }
                                    }
                                }
                            } label: {
                                Text("next")
                            }
                            .padding(30)
                        }
                    }
                } else {
                    Text("Assigning questions")
                        .font(.title)
                    ProgressView()
                }
            }
            .navigationTitle("Play")
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isPlay = false
                    } label: {
                        Text("back")
                    }

                }
            })
            .onAppear {
                Task {
                    if let book = book {
                        answers = await vm.answerdLogic.joinQuest(book: book)
                    }
                    if let books = books {
                        answers = await vm.answerdLogic.joinQuest(books: books)
                    }
                    if let answers = answers {
                        await vm.answerdLogic.prepareCache(answers: answers)
                    }
                    answer = vm.answerdLogic.nextQuestion()
                    if let answer = answer, let answers = answer.answers {
                        if (answer.answer >= answers.count) {
                            withAnimation {
                                isRevised = true
                                isAnswered = true
                            }
                        } else {
                            isRevised = false
                        }
                    }
                    print(isRevised)
                }
            }
        }
    }
    
    func ask(answer: Answers) -> some View {
        VStack {
            Text(answer.title)
                .font(.title)
            VStack {
                if isRevised, let answers = answer.answers {
                    ForEach(answers, id: \.self) { item in
                        itemAnswer(item.str)
                            .padding()
                    }
                } else if let answers = answer.answers {
                    ForEach(answers, id: \.self) { item in
                        itemAnswer(item.str, isCorrect: item.str == answers[answer.answer].str)
                            .padding()
                            .onTapGesture {
                                withAnimation {
                                    isAnswered = true
                                }
                            }
                    }
                }
            }
        }
    }
    
    func itemAnswer(_ text: String, isCorrect: Bool = false) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(.body)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isRevised
                                ? Color.primary.opacity(0.2)
                                : (isAnswered
                                    ? (isCorrect ? Color.green.opacity(0.5) : Color.red.opacity(0.5))
                                    : Color.primary.opacity(0.2)
                                  )
                        )
                )
            Spacer()
        }
    }
    
    var revisedAnswers: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.yellow.opacity(0.3))
            VStack {
                Spacer()
                Text("The current question has a contradictory error, since the correct question is not any of the possible ones, please review it.")
                    .padding()
                Spacer()
            }
        }
    }
}
