import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: загрузка
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        
        alertPresenter = AlertPresenterImplementation(viewController: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        presenter.viewController = self
    }
    
    
    //MARK: АУТЛЕТЫ
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    //MARK: КНОПКИ
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
                presenter.noButtonClicked()
    }
    
    
    //MARK: ПЕРЕМЕННЫЕ И КОНСТАНТЫ
    
    //про вопросы
    private var correctAnswers: Int = 0
    
    private let presenter = MovieQuizPresenter()

    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    //про алерт и статистику
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    
    //MARK: МЕТОДЫ
    
    
    //метод для показа индикатора
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    //метод для скрывания индикатора
    private func hideLoadingIndicator() {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    
    
    //метод для показа алерта с ошибкой
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать еще раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0

            self.questionFactory?.requestNextQuestion()
        }

        alert.addAction(action)
    }
    
    
    //метод для демонстрации, правильный ли был ответ
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
        
    }//ok
    
    //метод показа ответа
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //метод-конструктор показа результатов квиза
    private func showFinalResults(){
        statisticService?.store(correct: correctAnswers, count: presenter.currentQuestionIndex, total: presenter.questionsAmount) //сохраняем результат
        let alertModel = AlertModel(title: "Этот раунд окончен",
                                    message: resultMessage(),
                                    buttonText: "Сыграть еще раз",
                                    completion: { [weak self] _ in
                guard let self = self else { return }
            self.presenter.resetQuestionIndex()
                self.correctAnswers = 0 // скидываем счётчик правильных ответов
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(alertModel: alertModel)
        
    }
    
    //метод, который либо показывает следующий ответ, либо результат
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showFinalResults()
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()        }
    }
    
    //метод конструирования алерта
    private func resultMessage() -> String {
        guard let statisticService = statisticService else {
            assertionFailure("Ошибка")
            return ""
        }
        let bestGame = statisticService.bestGame
        
        let accurancy = String(format: "%.2f", statisticService.totalAccuracy) //обрубаем число до 2 знаков после запятой
        let totalPlaysString = "Количество сыгранных игр: \(statisticService.gamesCount)"
        let currentResultString = "Ваш результат: \(correctAnswers) из \(presenter.questionsAmount)"
        let bestGameString = "Рекорд: \(bestGame.correct) из \(bestGame.total)"
        + "(\(bestGame.date.dateTimeString))"
        let accurancyString = "Средняя точность: \(accurancy)%"
        
        let resultMessage = [totalPlaysString, currentResultString, bestGameString, accurancyString].joined(separator: "\n") //все сложили и разделили абзацами
        
        return resultMessage
    }
    
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        self.currentQuestion = question
        let viewModel = presenter.convert(model: question!)
        self.show(quiz: viewModel)
    }
    
}
