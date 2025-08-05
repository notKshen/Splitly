//
//  AddExpense.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-06.
//

import SwiftUI

struct AddExpenseView: View {
    @Binding var expenses: [Expense]
    @Environment(\.dismiss) var dismiss
    
    @State private var title:String = ""
    @State private var amount:String = ""
    @State private var date:Date = Date()
    @State private var paidBy:String = ""
    @State private var splitBetween:String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Group {
                        TextField("Title", text: $title)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray.opacity(0.2)))
                        TextField("Paid by", text: $paidBy)
                        TextField("Split between", text:$splitBetween)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    Button("Add Expense") {
                        addExpense()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(title.isEmpty || amount.isEmpty || paidBy.isEmpty ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.vertical)
                    .padding(.horizontal, 125)
                    .disabled(title.isEmpty || amount.isEmpty || paidBy.isEmpty)
                }
                .padding(.top, 30)
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
    
    func addExpense() {
        guard let amountValue = Double(amount) else {
            return
        }
        
        let people = splitBetween
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        let newExpense = Expense(
            title: title,
            amount: amountValue,
            date: date,
            paidBy: paidBy,
            splitBetween: people
        )
        
        expenses.append(newExpense)
        
        title = ""
        amount = ""
        date = Date()
        paidBy = ""
        splitBetween = ""
        
        dismiss()
    }
}

#Preview {
    AddExpenseView(expenses: .constant([]))
}
