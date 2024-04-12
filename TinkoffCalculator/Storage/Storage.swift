//
//  Storage.swift
//  TinkoffCalculator
//
//  Created by Арсений Варицкий on 11.04.24.
//

import Foundation

struct Calculation {
    let expression: [CalculatorHistoryItem]
    let result: Double
    let date: Date
}

extension Calculation: Codable { }

extension CalculatorHistoryItem: Codable {
    enum CodingKeys: String, CodingKey {
        case number
        case operation
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .number(let value):
            try container.encode(value, forKey: CodingKeys.number)
            
        case .operation(let value):
            try container.encode(value.rawValue, forKey: CodingKeys.operation)
        }
    }
    
    enum CalculatorHistoryItemError: Error {
        case itemNotFound
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let number = try container.decodeIfPresent(Double.self, forKey: .number) {
            self = .number(number)
            return
        }
        
        if let rawOperation = try container.decodeIfPresent(String.self, forKey: .operation),
           let operation = Operation(rawValue: rawOperation) {
            self = .operation(operation)
            return
        }
        throw CalculatorHistoryItemError.itemNotFound
    }
}

class CalculationHistoryStorage {
    
    static let calculationHistoryKey = "CalculationHistoryKey"
    
    func setHistory(calculation: [Calculation]) {
        if let encoded = try? JSONEncoder().encode(calculation) {
            UserDefaults.standard.set(encoded, forKey: CalculationHistoryStorage.calculationHistoryKey)
        }
    }
    
    func loadHistory() -> [Calculation] {
        if let data = UserDefaults.standard.data(forKey: CalculationHistoryStorage.calculationHistoryKey) {
            return (try? JSONDecoder().decode([Calculation].self, from: data)) ?? []
        }
        
        return [ ]
    }
}
