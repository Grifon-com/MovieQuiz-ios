import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var countLabel: UILabel!
    
    @IBOutlet private var textLabel: UILabel!
    
    
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //показываем первый вопрос
        show(quiz: convert(model: questions[currentQuestionIndex]))
        //отрисовываем рамку и красим в цвет View
        frameDrawing()
        self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                             question: model.text,
                                             questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
        if currentQuestionIndex == questions.count - 1 {
            // идём в состояние "Результат квиза"
            let textResult = "Ваш результат \(correctAnswers)/\(questions.count)"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен", text: textResult, buttonText: "Сыграть еще раз")
            showAlert(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            show(quiz: convert(model: questions[currentQuestionIndex]))
        }
    }
    //  метод отрисовки рамки
    private func frameDrawing() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
    
    //функция создания алерта и обнуления игры
    private func showAlert(quiz result:QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = (UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // обнуляем индекс текущего вопроса
            self.currentQuestionIndex = 0
            
            // обнуляем счетчик правильных ответов
            self.correctAnswers = 0
            
            // заново показываем первый вопрос 
            self.show(quiz: self.convert(model: self.questions[self.currentQuestionIndex]))
        })
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction  private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
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
 */
