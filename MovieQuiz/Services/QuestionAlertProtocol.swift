import Foundation
import UIKit

protocol QuestionAlertProtocol: AnyObject {
    func showAlert(modelAlert: AlertModel, vc: UIViewController)
}
