//
//  Debts.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-06.
//

import SwiftUI

struct Debts: View {
    @Binding var expenses: [Expense]
    
    var body: some View {
        let debts = calculateNetDebts(from: expenses)
        
        List {
            if debts.isEmpty {
                Text("No debts")
                    .foregroundStyle(.gray)
            } else {
                ForEach(debts.sorted(by: {$0.key < $1.key}), id: \.key) { key, amount in
                    Text("\(key): $\(amount, specifier: "%.2f")")
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    Debts(expenses: .constant([]))
}
