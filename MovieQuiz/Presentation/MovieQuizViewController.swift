import UIKit

final class MovieQuizViewController: UIViewController {
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactoryImpl(delegate: self)
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenterImplementation(viewController: self)
        statisticService = StatisticServiceImplementation()

        
    }
        
    
    //MARK: АУТЛЕТЫ
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    //MARK: КНОПКИ
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let givenAnswer = true
        sender.isEnabled = false
            
            showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.isEnabled = true
        }
        }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let givenAnswer = false
        sender.isEnabled = false
        
            showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.isEnabled = true
        }
    }
    
    //MARK: ПЕРЕМЕННЫЕ И КОНСТАНТЫ
    
    private var currentQuestionIndex: Int = 0 //ok
    private var correctAnswers: Int = 0 //ok
    
    private let questionsCount: Int = 10 //ok
    private var questionFactory: QuestionFactoryProtocol? //ok
    
    private var currentQuestion: QuizQuestion? //ok
    
    private var alertPresenter: AlertPresenterProtocol? //ok
    private var statisticService: StatisticService?
    
    //MARK: МЕТОДЫ
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)")
    } //ок
    
    private func showAnswerResult(isCorrect: Bool) {
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
        
    }

    private func show(quiz step: QuizStepViewModel) {
      imageView.image = step.image
      textLabel.text = step.question
      counterLabel.text = step.questionNumber
    } //ок
    
    private func showFinalResults(){
        statisticService?.store(correct: correctAnswers, count: currentQuestionIndex, total: questionsCount) //сохраняем результат
        let alertModel = AlertModel(
            title: "Этот раунд окончен",
            message: resultMessage(),
            buttonText: "Сыграть еще раз",
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0 // скидываем счётчик правильных ответов
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(alertModel: alertModel)
        
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsCount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()        }
    }//ok
    
    private func resultMessage() -> String {
        guard let statisticService = statisticService else {
            assertionFailure("Ошибка")
            return ""
        }
        let bestGame = statisticService.bestGame

        let accurancy = String(format: "%.2f", statisticService.totalAccuracy) //обрубаем число до 2 знаков после запятой
        let totalPlaysStr = "Количество сыгранных игр: \(statisticService.gamesCount)"
        let currentResultStr = "Ваш результат: \(correctAnswers) из \(questionsCount)"
        let bestGameStr = "Рекорд: \(bestGame.correct) из \(bestGame.total)"
        + "(\(bestGame.date.dateTimeString))"
        let avAccurancyStr = "Средняя точность: \(accurancy)%"
        
        let resultMessage = [totalPlaysStr, currentResultStr, bestGameStr, avAccurancyStr].joined(separator: "\n") //все сложили и разделили абзацами
        
        return resultMessage
    } //ok

}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        self.currentQuestion = question
        let viewModel = self.convert(model: question!)
        self.show(quiz: viewModel)
    }
    
}
