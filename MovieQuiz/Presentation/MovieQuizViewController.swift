import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var countLabel: UILabel!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var activitiIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statistic: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    /// переменная со счётчиком правильных ответов, начальное значение 0
    private var correctAnswers = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///создаем экземпляр alertPresenter
        alertPresenter = AlertPresenter()
        
        ///создаем экземпляр класса StatisticServiceImplementation
        statistic = StatisticServiceImplementation()
        
        ///инъецируем делегата
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader() , delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        ///показываем первый вопрос
        ///questionFactory?.requestNextQuestion()
        
        ///отрисовываем рамку
        frameDrawing()
        self.imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    /// метод сообщает об успешной загрузке
    func didLoadDataFromServer() {
        activitiIndicator.isHidden = true /// скрываем индикатор загрузки
        questionFactory?.requestNextQuestion() /// показывем первый вопрос
    }
    
    /// метод сообщает  об ошибке загрузки
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    /// приватный метод вывода на экран вопроса, который принимает на вход вью
    /// модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        countLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    /// приватный метод, который меняет цвет рамки, отключает и включает кнопки
    ///"ДА" и "НЕТ" принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        //отключаем взаимодействие с экраном во избежание множественного нажатия и некорректной работы
        view.isUserInteractionEnabled = false
        if isCorrect {
            correctAnswers += 1
        }
        
        frameDrawing()
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self]  in
            guard let self = self else { return }
            
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
            self.view.isUserInteractionEnabled = true
        }
    }
    
    ///приватный метод, который содержит логику перехода в один из сценариев
    ///метод ничего не принимает и ничего не возвращает
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            
            //извлекаем опционал
            guard var statistic = statistic else { return }
            
            /// метод сравнения текущего результата игры с сохраненным
            statistic.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            /// увеличиваем общее количество сыгранных игр на 1
            statistic.gamesCount += 1
            
            /// если игра запущена первый раз statistic.totalAccuracy будет назначен автоматически из результатов statistic.bestGame, если не первый, то к сохраненным результатам каждый раз будет прибавляться текущий результат для отображения статистики в алерте
            if statistic.gamesCount != 1 {
                statistic.totalAccuracy = Double(correctAnswers) / Double(presenter.questionsAmount)
            }
            
            /// высчитываем среднюю точность в процентах
            let averageAccuracy = (Double(statistic.totalAccuracy) / Double(statistic.gamesCount)) * 100
            
            /// константа для упрощения обращения к statistic.bestGame
            let record = statistic.bestGame
            
            /// текст для Alert.message
            let text = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n Количество сыгранных квизов: \(String(describing: statistic.gamesCount))\nРекорд: \(record.correct)/\(record.total) (\(record.date))\nСредняя точность: \(String(format: "%.2f", averageAccuracy))%"
            
            /// создаем AlertModel
            let viewAlertModel = AlertModel(title: "Этот раунд окончен!",
                                            message: text,
                                            buttonText: "Сыграть еще раз",
                                            /// completion hendler для действия по нажатию на кнопку алерта
                                            completion: { [weak self] in
                guard let self = self else {return}
                
                /// обнуляем индекс текущего вопроса
                self.presenter.resetQuestionIndex()
                
                /// обнуляем счетчик правильных ответов
                self.correctAnswers = 0
                
                /// заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()})
            
            alertPresenter?.showAlert(modelAlert: viewAlertModel, vc: self)
        } else {
            presenter.switchToNextQuestion()
            /// идём в состояние "Вопрос показан"
            questionFactory?.requestNextQuestion()
        }
    }
    ///  метод отрисовки рамки
    private func frameDrawing() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - AlertError
    
    ///функция отображения алерта с ошибкой
    private func showNetworkError(message: String) {
        let alertErrorViewModel = AlertModel(title: "Ошибка",
                                             message: message,
                                             buttonText: "Попробовать ещё раз",
                                             completion: { [weak self] in
            guard let self = self else {return}
            
            // обнуляем индекс текущего вопроса
            self.presenter.resetQuestionIndex()
            
            // обнуляем счетчик правильных ответов
            self.correctAnswers = 0
            
            
            // заново показываем первый вопрос
            self.questionFactory?.requestNextQuestion()})
        alertPresenter?.showAlert(modelAlert: alertErrorViewModel, vc: self)
    }
    
    /// метод показа индикатора загрузки
    private func showLoadingIndicator() {
        activitiIndicator.isHidden = false /// индикатор загрузки не скрыт
        activitiIndicator.startAnimating() /// включаем анимацию
    }
    
    
    @IBAction func yesButton(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction func noButton(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    
    
}

