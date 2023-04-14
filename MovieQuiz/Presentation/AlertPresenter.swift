import Foundation
import UIKit

class AlertPresenter: QuestionAlertDelegate {
    
    // метод показа Алерта
    func showAlert(modelAlert: AlertModel,  vc: UIViewController) {
            let alert = UIAlertController(
                title: modelAlert.title,
                message: modelAlert.message,
                preferredStyle: .alert)
            
        let action = UIAlertAction(title: modelAlert.buttonText, style: .default) { _ in modelAlert.completion() }
            alert.addAction(action)
            vc.present(alert, animated: true, completion: nil)
    }
}
