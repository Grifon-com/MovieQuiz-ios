import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var countLabel: UILabel!
    
    @IBOutlet private var textLabel: UILabel!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //создаем экземпляр alertPresenter
        alertPresenter = AlertPresenter()
        
        //создаем экземпляр класса StatisticServiceImplementation
        statistic = StatisticServiceImplementation()
        
        //инъецируем делегата
        questionFactory = QuestionFactory(delegate: self)
        
        //показываем первый вопрос
        questionFactory?.requestNextQuestion()
        //отрисовываем рамку и красим в цвет View
        frameDrawing()
        self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                             question: model.text,
                                             questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    //и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        countLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    // приватный метод, который меняет цвет рамки, отключает и включает кнопки "ДА" и "НЕТ"
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        //отключаем кнопки во избежание множественного нажатия и некорректной работы
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
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            //извлекаем опционал
            guard var statistic = statistic else { return }
            
            //метод сравнения текущего результата игры с сохраненным
            statistic.store(correct: correctAnswers, total: questionsAmount)
            
            //увеличиваем общее количество сыгранных игр на 1
            statistic.gamesCount = 1
            
            /*
             если игра запущена первый раз statistic.totalAccuracy будет назначен автоматически из результатов statistic.bestGame, если не первый, то к сохраненным результатам каждый раз будет прибавляться текущий результат для отображения статистики в алерте
             */
            if statistic.gamesCount != 1 {
                statistic.totalAccuracy = Double(correctAnswers) / Double(questionsAmount)
            }
            
            //высчитываем среднюю точность в процентах
            let st = (Double(statistic.totalAccuracy) / Double(statistic.gamesCount)) * 100
            
            // константа для упрощения обращения к statistic.bestGame
            let record = statistic.bestGame
            
            //текст для Alert.message
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n Количество сыгранных квизов: \(String(describing: statistic.gamesCount))\nРекорд: \(record.correct)/\(record.total) (\(record.date))\nСредняя точность: \(String(format: "%.2f", st))%"
            
            
            //создаем AlertModel
            let viewAlertModel = AlertModel(title: "Этот раунд окончен!",
                                            message: text,
                                            buttonText: "Сыграть еще раз",
                                            //completion hendler для действия по нажатию на кнопку алерта
                                            completion: { [weak self] in
                                            guard let self = self else {return}
                
                                            // обнуляем индекс текущего вопроса
                                            self.currentQuestionIndex = 0
                
                                            // обнуляем счетчик правильных ответов
                                            self.correctAnswers = 0
                
                                            // заново показываем первый вопрос
                                            self.questionFactory?.requestNextQuestion()})
            
            alertPresenter?.showAlert(modelAlert: viewAlertModel, vc: self)
        } else {
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            questionFactory?.requestNextQuestion()
        }
    }
    //  метод отрисовки рамки
    private func frameDrawing() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction  private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
