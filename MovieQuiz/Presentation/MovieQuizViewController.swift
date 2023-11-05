import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func showNetworkError() //-> Restart
    func showNetworkErrorWithUpdatePoster() //-> Update
    
    func showGameStatistics(record: GameRecord, alertModel: AlertModel)
    
    func showActivityIndicator()
    func hideActivityIndicator()
    
    func showQuestion(_ text: String?)
    
    func showPoster(_ image: UIImage)
    
    func showScoreLabel(_ text: String?)
    
    func showGreenBorder()
    func showRedBorder()
    
}

final class MovieQuizViewController: UIViewController {
    
    var presenter: MovieQuizPresenterProtocol?
    
    var isEnabled = true
    
    //MARK: - Views
    private let alertPresenter = AlertPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter?.viewDidAppear()
    }

    //MARK: - UI States
   
    

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.color = .white
        return activityIndicator
    }()
    
 
    
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
        
        label.accessibilityIdentifier = "Score"
        
        return label
    }()
    
    private let yesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нет", for: .normal)
        button.setTitleColor(Colors.ypBlack, for: .normal)
        button.backgroundColor = Colors.ypWhite
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.accessibilityIdentifier = "Yes"
        
        button.addTarget(nil, action: #selector(answerButtonTapped(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    private let noButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Да", for: .normal)
        button.setTitleColor(Colors.ypBlack, for: .normal)
        button.backgroundColor = Colors.ypWhite
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.accessibilityIdentifier = "No"
        
         button.addTarget(nil, action: #selector(answerButtonTapped(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 6
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let screenBounds = UIScreen.main.bounds
        imageView.heightAnchor.constraint(equalToConstant: screenBounds.height * 0.6).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: screenBounds.width * 0.8).isActive = true
        
        imageView.accessibilityIdentifier = "Poster"
        
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

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    
    func showGreenBorder() {
        posterImageView.layer.borderColor = Colors.ypGreen.cgColor
        posterImageView.layer.borderWidth = 5
    }
    func showRedBorder() {
        posterImageView.layer.borderColor = Colors.ypRed.cgColor
        posterImageView.layer.borderWidth = 5
    }
    
    func showScoreLabel(_ text: String?) {
        scoreLabel.text = text
    }

    func showGameStatistics(record: GameRecord, alertModel: AlertModel) {
        
        alertPresenter.showQuizResult(model: alertModel, controller: self)
        
        alertPresenter.completion = { [weak self] in
            //self?.restartGame()
            self?.presenter?.alertDidRetryRestart()
        }
    }
    
    func showPoster(_ image: UIImage) {
        posterImageView.layer.borderColor = UIColor.clear.cgColor
        posterImageView.layer.borderWidth = 0
        posterImageView.image = image
    }

    func showQuestion(_ text: String?) {
        self.questionLabel.text = text ?? ""// currentMovie?.question
        self.questionTextLabel.text = "Вопрос:"
    }

    func showNetworkError() {
        let alertModel = AlertModel(title: "Что-то пошло не так(", message: "Невозможно загрузить данные", buttonText: "Попробовать еще раз")
        alertPresenter.showQuizResult(model: alertModel, controller: self)
        alertPresenter.completion = { [weak self] in
            self?.presenter?.alertDidRetryRestart()
        }
    }
    
    func showNetworkErrorWithUpdatePoster() {
        let alertModel = AlertModel(title: "Что-то пошло не так(", message: "Невозможно загрузить данные", buttonText: "Попробовать еще раз")
        alertPresenter.showQuizResult(model: alertModel, controller: self)
        alertPresenter.completion = { [weak self] in
            //self?.presenter?.alertDidRetryRestart()
            self?.presenter?.alertDidRetryUpdatePoster()
        }
    }
    
    func showActivityIndicator() {
        if !activityIndicator.isDescendant(of: view) {
            view.addSubview(activityIndicator)
        }
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.center = view.center
    }
    
    func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}

//MARK: Event Handler
extension MovieQuizViewController {
    
   
    @objc private func answerButtonTapped(sender: UIButton) {
        
        if isEnabled == true {
            isEnabled = false
            
            presenter?.answerButtonDidTap(sender)
 
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isEnabled = true
            }
        }
    }
}
