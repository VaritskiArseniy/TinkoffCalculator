//
//  HistoryCollectionViewCell.swift
//  TinkoffCalculator
//
//  Created by Арсений Варицкий on 8.04.24.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var expressionLabel: UILabel!
    @IBOutlet private weak var resultLabel: UILabel!
    
    func configure(with expression: String, result: String){
        expressionLabel.text = expression
        resultLabel.text = result
    }
}
