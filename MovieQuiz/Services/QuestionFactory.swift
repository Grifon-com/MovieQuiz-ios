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
    
    
    /// собственная ошибка
    struct MyError: Error {
        let localizedDescription = "Failed to load image"
    }
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoder = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoder.loadMovies {[weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                /// проверяем ответ с сервера
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items /// сохраняем фильмы в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() /// сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) /// сообщаем о ошибке
                }
            }
        }
    }
    
    //получаем случайный фильм
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                /// ???????
                /// здесь я решил попробовать создать свою ошибку и в случае неудачной загрузки картинки передать ошибку как сообщение для алерта (прошу не защитывать как ошибку🙏)
                DispatchQueue.main.async {[weak self] in
                    guard let self = self else {return}
                    let myError = MyError()
                    self.delegate?.didFailToLoadData(with: myError)
                }
                
                let rating = Float(movie.rating) ?? 0
                let randomArrayRating = 6...9
                let randomRating = randomArrayRating.randomElement() ?? 7
                let text = "Рейтинг этого фильма больше чем \(randomRating)?"
                let correctAnswer = rating > Float(randomRating)
                
                let question = QuizQuestion(image: imageData,
                                            text: text,
                                            correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
        }
    }
    
}
