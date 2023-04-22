import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoder: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []

    /* массив вопросов
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
     */
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoder = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoder.loadMovies {[weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
            case .failure(let error):
                self.delegate?.didFailToLoadData(with: error)
            }
        }
    }
    
    //получаем случайный вопрос
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
}
