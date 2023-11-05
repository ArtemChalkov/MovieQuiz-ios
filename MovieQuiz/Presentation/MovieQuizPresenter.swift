//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Artur Igberdin on 05.11.2023.
//

import UIKit

//Responsibilities
//1. Services
//2. Models
//3. View Events

protocol MovieQuizPresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewDidAppear()
    
    func alertDidRetryRestart()
    func alertDidRetryUpdatePoster()
    
    func answerButtonDidTap(_ sender: UIButton)
}

class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewControllerProtocol?
    
    //MARK: Services
    private let questionFactory = QuestionFactory()
    private var statisticsService: StatisticService = StatisticServiceImplementation()
    private let reachability = Reachability()
    
    //MARK: Properties
    private var movies: [QuizQuestion] = []
    private var currentMovie: QuizQuestion?
    private lazy var moviesCount = movies.count
    private var count = 0 //Count of valid answers
    
}

extension MovieQuizPresenter: MovieQuizPresenterProtocol {
    
    func answerButtonDidTap(_ sender: UIButton) {
        
        if let buttonTitle = sender.titleLabel?.text {
            let movieTitle = currentMovie?.answer ?? ""

            if buttonTitle == movieTitle {
                viewController?.showGreenBorder()
                if reachability.isConnectedToNetwork() == true {
                    count += 1
                }
            } else {
                viewController?.showRedBorder()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.nextQuestion()
        }
        
    }
    
    func viewDidLoad() {
        statisticsService.gameCount += 1
    }
    func viewDidAppear() {
        restartGame()
    }
    func alertDidRetryRestart() {
        restartGame()
    }
    
    func alertDidRetryUpdatePoster() {
        updatePoster()
    }

}

//MARK: - Business Logic
extension MovieQuizPresenter {
    
    private func restartGame() {
    
        if reachability.isConnectedToNetwork() == false {
            viewController?.showNetworkError()
            return
        }
        
        viewController?.showActivityIndicator()
        questionFactory.loadData { [weak self] error in
            
            guard let self = self else { return }
            
            if error != nil {
                viewController?.showNetworkError()
                return
            }

            viewController?.hideActivityIndicator()
            
            movies = questionFactory.questions
            moviesCount = movies.count //setup all questions

            count = 0 //count make null
            statisticsService.gameCount += 1
            statisticsService.store()
            
            viewController?.showQuestion(currentMovie?.question)
            
            nextQuestion() //start 1 question
        }
    }
    
    private func nextQuestion() {
        
        if reachability.isConnectedToNetwork() == false {
            
            viewController?.showNetworkErrorWithUpdatePoster()
            return
        }
        
        if questionFactory.copyMovies.isEmpty
            {
            
            let recordModel = GameRecord.init(questionsCount: moviesCount, validCount: count)
            statisticsService.update(model: recordModel)
            
            let alertModel = AlertModel.init(
                title: "Раунд окончен!",
                message: statisticsService.message,
                buttonText: "Сыграть ещё раз")
            
            viewController?.showGameStatistics(record: recordModel, alertModel: alertModel)
            
            return
        }
        
        let scoreText = "\(moviesCount - questionFactory.copyMovies.count + 1)/\(moviesCount)"
        viewController?.showScoreLabel(scoreText)

        currentMovie = questionFactory.requestNextQuestion()
 
        viewController?.showQuestion(currentMovie?.question)
        
        updatePoster()
    }
    
    private func updatePoster() {
        
        if let question = currentMovie {
            question.loadImage(completion: { [weak self] image in
                guard let self = self else { return }
                self.viewController?.showPoster(image)
            })
        }
    }
    
    
}
