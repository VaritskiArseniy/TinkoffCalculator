//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Арсений Варицкий on 28.03.24.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .substract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1 / number2
        }
    }
}

enum CalculatorHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {
    
    var shouldClearDisplay = false

    var noResults = true
    var calculations: [Calculation] = []
    var calculationHistory: [CalculatorHistoryItem] = []
    
    var calculationHistoryStorage = CalculationHistoryStorage()
    
    private let alertView: AlertView = {
        let screenBounds = UIScreen.main.bounds
        let alertHeight: CGFloat = 100
        let alertWeight: CGFloat = screenBounds.width - 40
        let x: CGFloat = screenBounds.width / 2 - alertWeight / 2
        let y: CGFloat = screenBounds.height / 2 - alertHeight / 2
        let alertFrame = CGRect(x: x, y: y, width: alertWeight, height: alertHeight)
        let alertView = AlertView(frame: alertFrame)
        return alertView
    }()
    
    let longPressAnimationView = LongPressAnimationView()
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var historyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabelText()
        historyButton.accessibilityIdentifier = "historyButton"
        calculations = calculationHistoryStorage.loadHistory()
        
        view.addSubview(alertView)
        alertView.alpha = 0
        alertView.alertText = "Вы нашли пасхалку!"
        
        view.subviews.forEach {
            if type(of: $0) == UIButton.self {
                $0.layer.cornerRadius = 45
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else { return }
        
        if shouldClearDisplay {
            resetLabelText()
            shouldClearDisplay = false
        }
        
        if label.text == "Ошибка" {resetLabelText()}
        
        if buttonText == "," && label.text?.contains(",") == true {return}
        
        if label.text == "0" && buttonText != "," {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
        
        if label.text == "3,141592" {
            animateAlert()
        }
        
        sender.animateTap()
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        if label.text == "Ошибка" {resetLabelText()}
        
        guard let operationValue = sender.currentTitle,
              let operation = Operation(rawValue: operationValue),
              let displayText = label.text,
              let number = numberFormatter.number(from: displayText)?.doubleValue else { return }
        
        calculationHistory.append(.number(number))
        calculationHistory.append(.operation(operation))
        resetLabelText()
        }
        
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetLabelText()
    }
    
    func resetLabelText() {
        label.text = "0"
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
            let date = Date()
            let newCalculation = Calculation(expression: calculationHistory, result: result, date: date)
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
        }
        catch {
            label.text = "Ошибка"
            label.shake()
        }
        calculationHistory.removeAll()
        
        }
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        if let vc = calculationsListVC as? CalculationsListViewController {
                vc.calculations = calculations
        }
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }

        var currentResult = firstNumber
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation ) = calculationHistory[index],
                case.number(let number) = calculationHistory[index + 1]
            else { break }

            currentResult = try operation.calculate(currentResult, number)
            noResults = false
        }

        shouldClearDisplay = true

        return currentResult
    }
    
    private func animateAlert() {
        
        if !view.contains(alertView) {
            alertView.alpha = 0
            alertView.center = view.center
            view.addSubview(alertView)
        }
        
        UIView.animateKeyframes(withDuration: 2, delay: 0.5) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.alertView.alpha = 1
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                var newCenter = self.label.center
                newCenter.y -= self.alertView.bounds.height
                self.alertView.center = newCenter
            }
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            longPressAnimationView.startAnimation()
        } else if gesture.state == .ended {
            longPressAnimationView.stopAnimation()
        }
    }
}

extension UILabel {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5, y: center.y))
        layer.add(animation, forKey: "position")
    }
}

extension UIButton {

    func animateTap(){
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 0.9, 1]
        scaleAnimation.keyTimes = [0, 0.2, 1]
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.4, 0.9, 1]
        opacityAnimation.keyTimes = [0, 0.2, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        
        layer.add(animationGroup, forKey: "group")
    }
}

protocol LongPressViewProtocol {
    var shared: UIView { get }
    func startAnimation()
    func stopAnimation()
}

class LongPressAnimationView: UIView, LongPressViewProtocol {
    
    lazy var shared: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .blue
        view.layer.cornerRadius = 20
        return view
    }()
    
    func startAnimation() {
        guard !subviews.contains(shared) else { return }
        addSubview(shared)
        shared.center = center
        UIView.animate(withDuration: 0.5) {
            self.shared.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    func stopAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.shared.transform = .identity
        }) { _ in
            self.shared.removeFromSuperview()
        }
    }
}
