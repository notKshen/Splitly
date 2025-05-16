//
//  Home.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-06.
//

import SwiftUI

struct Home: View {
    @Binding var expenses: [Expense]
    
    var body: some View {
        List(expenses) { expense in
            VStack {
                Text(expense.title)
                    .font(.headline)
                Text("$\(expense.amount, specifier: "%.2f") • Paid by \(expense.paidBy)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.gray)
                ForEach(expense.debts.sorted(by: {$0.key < $1.key}), id: \.key) { person, amount in
                    Text("\(person) owes $\(amount, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    Home(expenses: .constant([
        Expense(
            title: "Dinner at Joe's",
            amount: 42.75,
            date: Date(),
            paidBy: "Kobe",
            splitBetween: ["Kobe", "Alex", "Sam"]
        )
    ]))
}
