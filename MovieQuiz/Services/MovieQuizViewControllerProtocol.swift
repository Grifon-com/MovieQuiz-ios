//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Григорий Машук on 12.05.23.
//

import Foundation

protocol MovieQuiezViewControllerProtocol {
    func show(quiz step: QuizStepViewModel)
    
    func trueUserInteractionEnabled()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func frameDrawing()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func showAlert(modelAlert: AlertModel)
    func showAlertResult()
}
