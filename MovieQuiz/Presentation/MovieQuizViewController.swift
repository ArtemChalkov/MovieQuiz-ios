import UIKit

// GameRecord(Model) -> BinaryObject(JSON) -> UserDefaults
// UserDefaults -> BinaryObject(JSON) -> GameRecord(Model)

struct GameRecord: Codable {
    var gameCount: Int = 1
    var questionsCount: Int = 10 //kolichestvo igr
    var validCount: Int = 6 //kolichestvo pravilnih
    var date: Date = Date()
    
    var record: String {
        return "\(validCount)/\(questionsCount)"
    }
    
    var percent: Double {
        return Double(questionsCount) / 100 //0.1
    }
    
    var averageAccuracy: String {
        
        let average = Double(validCount) / percent
        
        let formatted = String(format: "%.2f", average)
        return formatted + "%"
    }
    
    var currentDate: String {
        return Date().dateTimeString
    }
    
    func isBetterThan(_ another: GameRecord) -> Bool {
        validCount > another.validCount
    }
    
}

class StatisticServiceImplementation {
    
    var object: GameRecord?
   
    var message: String {
        guard let object else { return "" }
        
        var recordObject = recordObject ?? object
        
        if object.isBetterThan(recordObject) {
            recordObject = object
        }
        
        var value = """
        Ваш результат: \(object.record)
        Количество сыграных квизов: \(object.gameCount)
        Рекорд: \(recordObject.record) (\(recordObject.currentDate))
        Средняя точность: \(object.averageAccuracy)
        """
        
        return value
    }
    
    func update(model: GameRecord) {
        self.object = model
    }
    
    var recordObject: GameRecord? {
        
        if let recordData = UserDefaults.standard.data(forKey: "Record") {
            
            let decoder = JSONDecoder()
            do {
                let record = try decoder.decode(GameRecord.self, from: recordData)
                return record
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func store() {
        //1. Model -> Binary
        let jsonEncoder = JSONEncoder()
        
        guard let currentObject = object else { return }
        
        do {
    
            if let recordObject = recordObject {
                //if record > current -> break
                if recordObject.isBetterThan(currentObject) {
                    return
                }
            }
            
            //Binary
            let currentData = try jsonEncoder.encode(object)
            
            //2. Binary -> UserDefaults
            UserDefaults.standard.set(currentData, forKey: "Record")
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    //var completion: ()->()
}

class AlertPresenter {
    
    var completion: (()->())?
    
    func showQuizResult(model: AlertModel, controller: UIViewController) {
        
        let alert = UIAlertController(
            title: model.title, //"Раунд окончен!",
            message: model.message, //"Ваш результат: \(count)/10",
            preferredStyle: .alert)
        
        let continueAction = UIAlertAction.init(
            title: model.buttonText, //"Сыграть ещё раз",
            style: .default) { action in
                
                print(action, #line)
                
                self.completion?()
                
                //self.restartGame()
            }
        
        alert.addAction(continueAction)
        controller.present(alert, animated: true)
    }
}

final class MovieQuizViewController: UIViewController {
    
    //Services
    private let questionFactory = QuestionFactory()
    private let alertPresenter = AlertPresenter()
    private let statisticsService = StatisticServiceImplementation()
    
    private lazy var movies = questionFactory.questions
    
    private var currentMovie: QuizQuestion?
    
    private lazy var moviesCount = movies.count
    
    private var count = 0 //Count of valid answers
    
    private var gameCount = 0 //Count of games
    
    private lazy var copyMovies = movies
    
    
    //MARK: - Business Logic
    
    private func restartGame() {
        
        moviesCount = movies.count //setup all questions
        
        copyMovies = movies //setup all movies in array
        
        count = 0 //count make null
        
        gameCount += 1
        
        statisticsService.store()
        
        
        nextQuestion() //start 1 question
    }
    
    private func nextQuestion() {
        
        if copyMovies.isEmpty {
            
            let model = GameRecord.init(gameCount: gameCount, questionsCount: moviesCount, validCount: count)
            statisticsService.update(model: model)
            
            let alertModel = AlertModel.init(
                title: "Раунд окончен!",
                message: statisticsService.message,
                buttonText: "Сыграть ещё раз")
                
            
            alertPresenter.showQuizResult(model: alertModel, controller: self)
            
            alertPresenter.completion = {
                self.restartGame()
            }
            return
        }
        
        scoreLabel.text = "\(moviesCount - copyMovies.count + 1)/\(moviesCount)"
        currentMovie = copyMovies.removeFirst()
        update()
    }
    
    //MARK: - UI States
    private func update() {
        
        if let question = currentMovie {
            
            posterImageView.layer.borderColor = UIColor.clear.cgColor
            posterImageView.layer.borderWidth = 0
            
            let image = UIImage(named: question.image)
            
            posterImageView.image = image
        }
    }
    var isEnabled = true
    
    //MARK: - Events
    @objc private func checkQuestionTapped(sender: UIButton) {
        
        if isEnabled == true {
            isEnabled = false
            if let buttonTitle = sender.titleLabel?.text {
                let movieTitle = currentMovie?.answer ?? ""
                print(buttonTitle, movieTitle)
                
                if buttonTitle == movieTitle {
                    posterImageView.layer.borderColor = Colors.ypGreen.cgColor
                    posterImageView.layer.borderWidth = 5
                    
                    count += 1
        
                } else {
                    posterImageView.layer.borderColor = Colors.ypRed.cgColor
                    posterImageView.layer.borderWidth = 5
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isEnabled = true
                self.nextQuestion()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        gameCount = 1
        
        nextQuestion()
    }
    
    //Closure init
    private let questionTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Вопрос:"
        label.font = UIFont(name: "YSDisplay-Medium", size: 20)
        label.textColor = Colors.ypWhite
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
        
        button.addTarget(self, action: #selector(checkQuestionTapped(sender:)), for: .touchUpInside)
        
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
        
        button.addTarget(self, action: #selector(checkQuestionTapped(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "poster1")
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 6
        imageView.clipsToBounds = true
        imageView.layer.borderColor = Colors.ypRed.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
            posterImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -178),
            posterImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            posterImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            posterImageView.widthAnchor.constraint(equalToConstant: 335),
            //posterImageView.heightAnchor.constraint(equalToConstant: 502)

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
