import UIKit


final class MovieQuizViewController: UIViewController {
    
    //Services
    private let questionFactory = QuestionFactory()
    private let alertPresenter = AlertPresenter()
    private var statisticsService: StatisticService = StatisticServiceImplementation()
    private let reachability = Reachability()
    
    private var movies: [QuizQuestion] = []
    
    private var currentMovie: QuizQuestion?
    
    private lazy var moviesCount = movies.count
    
    private var count = 0 //Count of valid answers
    
    //private var gameCount = 0 //Count of games
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        statisticsService.gameCount += 1

        
        restartGame()
    }
    
    //MARK: - Business Logic
    
    
    private func nextQuestion() {
        
        if reachability.isConnectedToNetwork() == false {
            
            let alertModel = AlertModel(title: "Что-то пошло не так(", message: "Невозможно загрузить данные", buttonText: "Попробовать еще раз")
            alertPresenter.showQuizResult(model: alertModel, controller: self)
            
            alertPresenter.completion = { [weak self] in
                //self?.restartGame()
                self?.update()
            }
            return
        }
        
        if questionFactory.copyMovies.isEmpty
            {
            
            let model = GameRecord.init(questionsCount: moviesCount, validCount: count)
            statisticsService.update(model: model)
            
            let alertModel = AlertModel.init(
                title: "Раунд окончен!",
                message: statisticsService.message,
                buttonText: "Сыграть ещё раз")

            alertPresenter.showQuizResult(model: alertModel, controller: self)
            
            alertPresenter.completion = { [weak self] in
                self?.restartGame()
            }
            return
        }
        
        scoreLabel.text = "\(moviesCount - questionFactory.copyMovies.count + 1)/\(moviesCount)"
        
        currentMovie = questionFactory.requestNextQuestion()
        
        self.questionLabel.text = currentMovie?.question
       
        
        update()
    }
    
    private func restartGame() {
    
        if reachability.isConnectedToNetwork() == false {
            
            let alertModel = AlertModel(title: "Что-то пошло не так(", message: "Невозможно загрузить данные", buttonText: "Попробовать еще раз")
            alertPresenter.showQuizResult(model: alertModel, controller: self)
            
            alertPresenter.completion = { [weak self] in
                //self?.restartGame()
                self?.update()
            }
            return
        }
        
        showActivityIndicator()
        questionFactory.loadData { [weak self] error in
            
            guard let self = self else { return }
            
            if error != nil {
                let alertModel = AlertModel(title: "Что-то пошло не так(", message: "Невозможно загрузить данные", buttonText: "Попробовать еще раз")
                alertPresenter.showQuizResult(model: alertModel, controller: self)
                
                alertPresenter.completion = { [weak self] in
                    self?.restartGame()
                }
                
                return
            }

            self.hideActivityIndicator()
            
            movies = questionFactory.questions
            
            moviesCount = movies.count //setup all questions
            
            //questionFactory.copyMovies = movies //setup all movies in array
            
            self.count = 0 //count make null
            self.statisticsService.gameCount += 1
            self.statisticsService.store()
            
            self.questionLabel.text = currentMovie?.question
            self.questionTextLabel.text = "Вопрос:"
            
            nextQuestion() //start 1 question
        }
        
       
    }
   
    
    //MARK: - UI States
    private func update() {
        
        if let question = currentMovie {
            posterImageView.layer.borderColor = UIColor.clear.cgColor
            posterImageView.layer.borderWidth = 0
            question.loadImage(completion: { image in
                 self.posterImageView.image = image
            })
        }
    }
    var isEnabled = true
    
    //MARK: - Actions
    @objc private func checkQuestionTapped(sender: UIButton) {
        
        if isEnabled == true {
            isEnabled = false
            if let buttonTitle = sender.titleLabel?.text {
                let movieTitle = currentMovie?.answer ?? ""
                
                
                if buttonTitle == movieTitle {
                    posterImageView.layer.borderColor = Colors.ypGreen.cgColor
                    posterImageView.layer.borderWidth = 5
                    
                    if reachability.isConnectedToNetwork() == true {
                        count += 1
                    }
        
                } else {
                    posterImageView.layer.borderColor = Colors.ypRed.cgColor
                    posterImageView.layer.borderWidth = 5
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isEnabled = true
                self.nextQuestion()
            }
        }
    }

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    private func showActivityIndicator() {
        if !activityIndicator.isDescendant(of: view) {
            view.addSubview(activityIndicator)
        }
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.center = view.center
    }
    
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private let questionTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Вопрос:"
        label.font = UIFont(name: "YSDisplay-Medium", size: 20)
        label.textColor = Colors.ypWhite
        //label.backgroundColor = .yellow
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Рейтинг этого фильма меньше чем 5?"
        label.font = UIFont(name: "YSDisplay-Bold", size: 23)
        label.textColor = Colors.ypWhite
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "1/10"
        label.font = UIFont(name: "YSDisplay-Medium", size: 20)
        label.textColor = Colors.ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let yesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нет", for: .normal)
        button.setTitleColor(Colors.ypBlack, for: .normal)
        button.backgroundColor = Colors.ypWhite
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(nil, action: #selector(checkQuestionTapped(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    private let noButton: UIButton = {
        let button = UIButton()
        button.setTitle("Да", for: .normal)
        button.setTitleColor(Colors.ypBlack, for: .normal)
        button.backgroundColor = Colors.ypWhite
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        
         button.addTarget(nil, action: #selector(checkQuestionTapped(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        //imageView.image = UIImage(named: "poster1")
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 6
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let screenBounds = UIScreen.main.bounds
        imageView.heightAnchor.constraint(equalToConstant: screenBounds.height * 0.6).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: screenBounds.width * 0.8).isActive = true
        return imageView
    }()
    
    
    private func setupViews() {
        
        view.backgroundColor = Colors.ypBackground
        
        view.addSubview(questionTextLabel)
        view.addSubview(scoreLabel)
        view.addSubview(yesButton)
        view.addSubview(noButton)
        view.addSubview(questionLabel)
        view.addSubview(posterImageView)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            questionTextLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            questionTextLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20)
        ])
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            yesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            yesButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            yesButton.widthAnchor.constraint(equalToConstant: 158),
            yesButton.heightAnchor.constraint(equalToConstant: 60)

        ])
        NSLayoutConstraint.activate([
            noButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            noButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            noButton.widthAnchor.constraint(equalToConstant: 158),
            noButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        NSLayoutConstraint.activate([
            questionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -91),
            questionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -62),
            questionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 62),
        ])
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: questionTextLabel.bottomAnchor, constant: 20),
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)

        ])
    }
}


/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
