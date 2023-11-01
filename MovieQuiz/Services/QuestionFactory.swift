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
    
    //var movies: [MovieQuiz] = []
    
    
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
    
    func convertToQuizQuestions(_ movies: [MostPopularMovie]) -> [QuizQuestion]  {
        var questions: [QuizQuestion] = []
        
        for movie in movies {
            
            let randomId = Int.random(in: 0...10000)
        
            let realRating = Double(movie.rating) ?? 0.0 //5
            
            let randomRating = Double.random(in: 5.5...9.9) //7
            
            var questionText = "Рейтинг этого фильма больше чем \(Int(randomRating))? "
            
            let answer: String
            if randomRating < realRating {
                answer = "Да"
            } else {
                answer = "Нет"
            }
            
            
            let quizQuestion = QuizQuestion.init(id: randomId, image: movie.imageURL, rating: realRating, question: questionText, answer: answer)
            
            //[PopularMoview] -> [QuizMovie]
            questions.append(quizQuestion)
            
        }
        return questions
    }

    
    var questions: [QuizQuestion] = []
//    [
//        QuizQuestion.init(id: 1, image: "The Godfather", rating: 9.2, question: "Рейтинг этого фильма больше чем 6?", answer: "Да"),
//        QuizQuestion.init(id: 2, image: "The Dark Knight", rating: 9, question: "Рейтинг этого фильма больше чем 6?", answer: "Да"),
//        QuizQuestion.init(id: 3, image: "Kill Bill", rating: 8.1, question: "Рейтинг этого фильма больше чем 6?", answer: "Да"),
//        QuizQuestion.init(id: 4, image: "The Avengers", rating: 8, question: "Рейтинг этого фильма больше чем 6?", answer: "Да"),
//        QuizQuestion.init(id: 5, image: "Deadpool", rating: 8, question: "Рейтинг этого фильма больше чем 6?", answer: "Да"),
//        QuizQuestion.init(id: 6, image: "The Green Knight", rating: 6.6, question: "Рейтинг этого фильма больше чем 6?", answer: "Да"),
//        QuizQuestion.init(id: 7, image: "Old", rating: 5.8, question: "Рейтинг этого фильма больше чем 6?", answer: "Нет"),
//        QuizQuestion.init(id: 8, image: "The Ice Age Adventures of Buck Wild", rating: 4.3, question: "Рейтинг этого фильма больше чем 6?", answer: "Нет"),
//        QuizQuestion.init(id: 9, image: "Tesla", rating: 5.1, question: "Рейтинг этого фильма больше чем 6?", answer: "Нет"),
//        QuizQuestion.init(id: 10, image: "Vivarium", rating: 5.8, question: "Рейтинг этого фильма больше чем 6?", answer: "Нет")
//    ]
    
    func requestNextQuestion() -> QuizQuestion? {
        
        guard let question = copyMovies.randomElement() else { return nil }
        
        copyMovies.removeAll(where: { $0.id == question.id } )
        
        return question
    }

}


