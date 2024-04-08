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
    var calculations: [(expression: [CalculatorHistoryItem], result: Double)] = []
    var calculationHistory: [CalculatorHistoryItem] = []
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var historyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabelText()
        historyButton.accessibilityIdentifier = "historyButton"
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
            calculations.append((calculationHistory, result))
        }
        catch {
            label.text = "Ошибка"
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
    
}
