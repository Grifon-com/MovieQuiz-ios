import Foundation
import UIKit

protocol QuestionAlertDelegate: AnyObject {
    func showAlert(modelAlert: AlertModel, vc: UIViewController)
}
