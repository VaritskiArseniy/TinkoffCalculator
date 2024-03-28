//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Арсений Варицкий on 28.03.24.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        print(buttonText)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Та-дам!")
    }
}

