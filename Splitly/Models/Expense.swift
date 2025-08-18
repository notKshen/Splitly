//
//  Expense.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-11.
//

import Foundation

struct Expense: Identifiable, Hashable, Decodable {
    let id: String
    let groupID: String
    var title: String
    var amount: Double
    var date: Date
    var paidBy: String
    var splitBetween: [String]
    
    var individualShares: Double {
        amount / Double(splitBetween.count)
    }
    
    var debts: [String: Double] {
        var result: [String: Double] = [:]
        for person in splitBetween {
            if person != paidBy {
                result[person] = individualShares
            }
        }
        return result
    }
    
    init(id: String = UUID().uuidString, groupID: String, title: String, amount: Double, date: Date, paidBy: String, splitBetween: [String]) {
        self.id = id
        self.groupID = groupID
        self.title = title
        self.amount = amount
        self.date = date
        self.paidBy = paidBy
        self.splitBetween = splitBetween
    }
}

func calculateNetDebts(from expenses: [Expense]) -> [String: Double] {
    var balances: [String: [String: Double]] = [:]
    for expense in expenses {
        let payer = expense.paidBy
        let share = expense.individualShares
        
        for person in expense.splitBetween where person != payer {
            balances[person, default: [:]][payer, default: 0] += share
        }
    }
    
    var netDebts: [String: Double] = [:]
    
    for (debtor, creditors) in balances {
        for (creditor, amount) in creditors {
            let forwardKey = "\(debtor) -> \(creditor)"
            let reverseKey = "\(creditor) -> \(debtor)"
            
            if let reverseAmount = netDebts[reverseKey] {
                if reverseAmount > amount {
                    netDebts[reverseKey] = reverseAmount - amount
                } else if reverseAmount < amount {
                    netDebts[forwardKey] = amount - reverseAmount
                    netDebts.removeValue(forKey: reverseKey)
                } else {
                    netDebts.removeValue(forKey: reverseKey)
                }
            } else {
                netDebts[forwardKey] = amount
            }
        }
    }
    return netDebts
}
