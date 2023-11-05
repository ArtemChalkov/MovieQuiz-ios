//
//  File.swift
//  MovieQuiz
//
//  Created by Артем Чалков on 12.10.2023.
//

import UIKit

class QuestionFactory {
    
    var moviesLoader: MoviesLoading = MoviesLoader()
    
    var questionsAmount: Int = 10
    
    var copyMovies: [QuizQuestion] = []

    func loadData(completion: @escaping (Error?)->()) {
        
        moviesLoader.loadMovies { [weak self] result in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    //self.movies = mostPopularMovies.items
                    //self.delegate?.didLoadDataFromServer()
                    var shuffledFilms = Array(mostPopularMovies.items.shuffled())
                    let movies = Array(shuffledFilms[0..<10])
                    
                    self.questions = self.convertToQuizQuestions(movies)
                    
                    self.copyMovies = self.questions
                    
                    completion(nil)
                    
                case .failure(let error):
                    
                    completion(error)
                    
                    //self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func convert(model: MostPopularMovie) -> QuizQuestion {
        
//        struct MostPopularMovie: Codable {
//            let title: String
//            let rating: String
//            let imageURL: URL
//
//            private enum CodingKeys: String, CodingKey {
//            case title = "fullTitle"
//            case rating = "imDbRating"
//            case imageURL = "image"
//            }
//        }
        
        let randomId = Int.random(in: 0...10000)
        
        let realRating = Double(model.rating) ?? 0.0 //5
        
        let randomRating = Double.random(in: 5.5...9.9) //7
        
        var questionText = "Рейтинг этого фильма больше чем \(Int(randomRating))? "
        
        let answer: String
        if randomRating < realRating {
            answer = "Да"
        } else {
            answer = "Нет"
        }
        
        let quizQuestion = QuizQuestion.init(id: randomId, image: model.imageURL, rating: realRating, question: questionText, answer: answer)
        
        return quizQuestion
    }
    
    //[MostPopularMovie] -> [QuizMovie]
    func convertToQuizQuestions(_ movies: [MostPopularMovie]) -> [QuizQuestion]  {
        var questions: [QuizQuestion] = []
        
        for movie in movies {
            let quizQuestion = convert(model: movie)
            questions.append(quizQuestion)
        }
        return questions
    }
    
    var questions: [QuizQuestion] = []

    
    func requestNextQuestion() -> QuizQuestion? {
        
        guard let question = copyMovies.randomElement() else { return nil }
        
        copyMovies.removeAll(where: { $0.id == question.id } )
        
        return question
    }

}


