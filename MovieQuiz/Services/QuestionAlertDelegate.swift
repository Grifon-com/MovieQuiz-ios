import Foundation

protocol QuestionAlertDelegate: AnyObject {
    func showAlert(modelAlert: AlertModel, vc: MovieQuizViewController)
}
