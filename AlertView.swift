//
//  AlertView.swift
//  TinkoffCalculator
//
//  Created by Арсений Варицкий on 12.04.24.
//

import Foundation
import UIKit

class AlertView: UIView {
    
    var alertText: String? {
        didSet {
            label.text = alertText
        }
    }
    
    private let label: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(label)
        backgroundColor = .red
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        addGestureRecognizer(tap)
    }
    
    @objc
    private func hide() {
        removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    
}
