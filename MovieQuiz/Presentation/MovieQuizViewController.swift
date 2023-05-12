import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activitiIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        
        ///отрисовываем рамку imageView
        frameDrawing()
    }
    
    //MARK: - Actions
    
    @IBAction private func yesButton(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction func noButton(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - ShowUIView
    /// приватный метод вывода на экран вопроса, который принимает на вход вью
    /// модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        countLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    func trueUserInteractionEnabled() {
        self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
        self.view.isUserInteractionEnabled = true
    }
    
    func highhligghtImageBorder(isCorrectAnswer: Bool) {
        //отключаем взаимодействие с экраном во избежание множественного нажатия и некорректной работы
        self.view.isUserInteractionEnabled = false
        
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    ///  метод отрисовки рамки
    func frameDrawing() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        self.imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    /// метод показа индикатора загрузки
    func showLoadingIndicator() {
        activitiIndicator.isHidden = false /// индикатор загрузки не скрыт
        activitiIndicator.startAnimating() /// включаем анимацию
    }
    
    /// метод скрытия индиактора загрузки
    func hideLoadingIndicator() {
        activitiIndicator.isHidden = true
    }
    
    // MARK: - ShowAlert
    
    /// метод отображения алерта с ошибкой
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertErrorViewModel = AlertModel(title: "Ошибка",
                                             message: message,
                                             buttonText: "Попробовать ещё раз",
                                             completion: { [weak self] in
            guard let self = self else {return}
            self.presenter.restartGame()
        })
        
        showAlert(modelAlert: alertErrorViewModel)
    }
    
    // метод показа Алерта
    func showAlert(modelAlert: AlertModel) {
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
        self.present(alert, animated: true, completion: nil)
    }
    
    // метод паказа олерта с результатами статистики
    func showAlertResult() {
        let message = presenter.resultMessage()
        
        /// создаем AlertModel
        let viewAlertModel = AlertModel(title: "Этот раунд окончен!",
                                        message: message,
                                        buttonText: "Сыграть еще раз",
                                        /// completion hendler для действия по нажатию на кнопку алерта
                                        completion: { [weak self] in
            guard let self = self else {return}
            
            self.presenter.restartGame()})
        
        self.showAlert(modelAlert: viewAlertModel)
    }
}

