//
//  RandomAnswerLogic.swift
//  AIQuestion
//
//  Created by Jose Decena on 25/9/24.
//

import Foundation

final class RandomQuestLogic {
    
    static let shere = RandomQuestLogic()
    var exponencialX = 2.0
    var exponencialY = 3.0
    var intoleranceReplica = 80
    
    private var cache = [Answers]()
    private var cacheAux: Answers?
    private var reserveQuestions = [Answers]()
    private var isTaskExecute = false
    
    func prepareCache(answers: [Answers]) async {
        reserveQuestions = answers
        var diccionarioPreguntaValor = [Answers:Double]()
        let numerovaloresCache: Int = max(answers.count / 100 * intoleranceReplica, 1)
        answers.prefix(numerovaloresCache).forEach { answer in
            let x = Double(answer.learningLevel)
            let y = answer.lastTimeAsked.timeIntervalSince(Date())
            let o2 = pow(exponencialY, y)
            let o1 = pow(exponencialY, x)
            let f: Double = o2 + o1
            diccionarioPreguntaValor[answer] = f
        }
        
        let arrayPreguntaValor = diccionarioPreguntaValor.sorted { p1, p2 in
            p1.value > p2.value
        }
        
        cache = arrayPreguntaValor.map({ arra in
            arra.key
        })
        
        cache = cache.filter { pregunta in
            pregunta != cacheAux
        }
    }
    
    func nextQuestion() -> Answers {
        if cache.isEmpty {
            if !isTaskExecute {
                isTaskExecute = true
                Task {
                    await prepareCache(answers: reserveQuestions)
                    isTaskExecute = false
                }
                if let cacheAux = cacheAux {
                    let segureQuestionRandom = reserveQuestions.filter { pregunta in
                        pregunta.id != cacheAux.id
                    }
                    self.cacheAux = segureQuestionRandom[Int.random(in: 0 ..< segureQuestionRandom.count)]
                    return self.cacheAux!
                }
                return reserveQuestions[Int.random(in: 0 ..< reserveQuestions.count)]
            }
        }
        let spontaneousCache = cache.removeFirst()
        if cacheAux?.id == spontaneousCache.id {
            let id = cacheAux?.id
            let segureQuestionRandom = reserveQuestions.filter { pregunta in
                pregunta.id != id
            }
            self.cacheAux = segureQuestionRandom[Int.random(in: 0 ..< segureQuestionRandom.count)]
            return self.cacheAux!
        }
        cacheAux = spontaneousCache
        return cacheAux!
    }
    
    
    func UpdateCriteria(answer: Answers, selected: Int){

        if answer.answer != selected {
            if answer.learningLevel < 5 {
                answer.learningLevel = answer.learningLevel + 1
            }
        } else {
            if answer.learningLevel > 1 {
                answer.learningLevel = answer.learningLevel - 1
            }
        }
        answer.lastTimeAsked = Date()
    }
    
    
    func joinQuest(books: [Books]) async -> [Answers]{
        var answers = [Answers]()
        books.forEach { book in
            if let topics = book.topics {
                topics.forEach { topic in
                    if let answersAux = topic.answers {
                        answers.append(contentsOf: answersAux)
                    }
                }
            }
        }
        
        return answers
    }
    
    func joinQuest(book: Books) async -> [Answers] {
        var questions = [Answers]()
        if let topic = book.topics {
            topic.forEach { tema in
                if let answersAux = tema.answers {
                    questions.append(contentsOf: answersAux)
                }
            }
        }
        return questions
    }
    
    func isEmpty(items: [Any]) -> Bool {
        var aux = 0
        if let books = items as? [Books] {
            for book in books {
                for topic in book.topics! {
                    if !topic.answers!.isEmpty {
                        aux = aux + topic.answers!.count
                    }
                    if aux >= 2 {
                        return false
                    }
                }
            }
        } else if let topics = items as? [Topics] {
            for topic in topics {
                if !topic.answers!.isEmpty {
                    aux = aux + topic.answers!.count
                }
                if aux >= 2 {
                    return false
                }
            }
        } else if let answers = items as? [Answers] {
            return answers.count < 2
        }
        return true
    }
    
}
