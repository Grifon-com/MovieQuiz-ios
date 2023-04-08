import Foundation

class QuestionFactory {

    // массив вопросов
    private let questions: [QuizQuestion] =
    [QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 9,2?", correctAnswer: true),
     QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 9?", correctAnswer: true),
     QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 8,1?", correctAnswer: true),
     QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 8?", correctAnswer: true),
     QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 8?", correctAnswer: true),
     QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6,6?", correctAnswer: true),
     QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 5,8?", correctAnswer: false),
     QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 4,3?", correctAnswer: false),
     QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 5,1?", correctAnswer: false),
     QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 5,8?", correctAnswer: false)
    ]
    
    //получаем случайный вопрос
    func requestNextQuestion() -> QuizQuestion? {                       // 1
        guard let index = (0..<questions.count).randomElement() else {  // 2
            return nil
        }
        return questions[safe: index]                           // 3
    }
    
}
