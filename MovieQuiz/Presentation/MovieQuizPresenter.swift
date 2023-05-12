//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Григорий Машук on 9.05.23.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    
    private var statisticService: StatisticService!
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    //метод подсчета правильных ответов
    func didAnswers(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        self.proceedWhithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    /// метод конвертации, который принимает  вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                             question: model.text,
                                             questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    /// приватный метод, который меняет цвет рамки, отключает и включает кнопки
    ///"ДА" и "НЕТ" принимает на вход булевое значение и ничего не возвращает
    private func proceedWhithAnswer(isCorrect: Bool) {
        self.didAnswers(isCorrectAnswer: isCorrect)
        self.viewController?.highhligghtImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self]  in
            guard let self = self else { return }
            self.viewController?.trueUserInteractionEnabled()
            self.proceedToNextQuestionOrResults()
        }
    }
    
    ///приватный метод, который содержит логику перехода в один из сценариев
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.showAlertResult()
        } else {
            self.switchToNextQuestion()
            /// идём в состояние "Вопрос показан"
            questionFactory?.requestNextQuestion()
        }
    }
    
    func resultMessage() -> String {
        /// константа для упрощения обращения к statistic.bestGame
        let record = statisticService.bestGame
        
        let averageAccuracy = statisticsUpdate()
        
        /// текст для Alert.message
        let text = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\n Количество сыгранных квизов: \(String(describing: statisticService.gamesCount))\nРекорд: \(record.correct)/\(record.total) (\(record.date))\nСредняя точность: \(String(format: "%.2f", averageAccuracy))%"
        
        return text
    }
    
    ///  метод обновления статистики
    private func statisticsUpdate() -> Double {
        /// метод сравнения текущего результата игры с сохраненным
        statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
        
        /// увеличиваем общее количество сыгранных игр на 1
        statisticService.gamesCount += 1
        
        /// если игра запущена первый раз statistic.totalAccuracy будет назначен автоматически из результатов statistic.bestGame, если не первый, то к сохраненным результатам каждый раз будет прибавляться текущий результат для отображения статистики в алерте
        if statisticService.gamesCount != 1 {
            statisticService.totalAccuracy = Double(correctAnswers) / Double(self.questionsAmount)
        }
        
        /// высчитываем среднюю точность в процентах
        let averageAccuracy = (Double(statisticService.totalAccuracy) / Double(statisticService.gamesCount)) * 100
        
        return averageAccuracy
    }
}
