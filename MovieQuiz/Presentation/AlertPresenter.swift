import Foundation
import UIKit

class AlertPresenter {
    
    // метод показа Алерта
    func showAlert(modelAlert: AlertModel, vc: UIViewController) {
        //создаем алерт
        let alert = UIAlertController(
            title: modelAlert.title,
            message: modelAlert.message,
            preferredStyle: .alert)
        
        // действие по кнопке алерта
        let action = UIAlertAction(title: modelAlert.buttonText, style: .default) { _ in
            //ативируем completion hendler
            modelAlert.completion()}
        
        //добавляем кнопку к алерту
        alert.addAction(action)
        
        //разрешаем показ алерта
        vc.present(alert, animated: true, completion: nil)
    }
}
