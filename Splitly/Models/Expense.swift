//
//  Expense.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-11.
//

import Foundation

struct Expense: Identifiable {
    let id: UUID = UUID()
    var title: String
    var amount: Double
    var date: Date
    var paidBy: String
    var splitBetween: [String]
}
