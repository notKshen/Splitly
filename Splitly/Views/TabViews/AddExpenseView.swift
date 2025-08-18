//
//  AddExpense.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-06.
//

import SwiftUI

struct AddExpenseView: View {
    let groupID: String
    let members: [UserProfile]
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var paidBy: String = ""
    @State private var selectedSplit: Set<String> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.2)))

                    // Paid By Picker
                    Picker("Paid by", selection: $paidBy) {
                        ForEach(members, id: \.id) { member in
                            Text(member.username).tag(member.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    // Split Between Picker (multi-select)
                    VStack(alignment: .leading) {
                        Text("Split between")
                            .font(.headline)
                        ForEach(members, id: \.id) { member in
                            Button {
                                if selectedSplit.contains(member.id) {
                                    selectedSplit.remove(member.id)
                                } else {
                                    selectedSplit.insert(member.id)
                                }
                            } label: {
                                HStack {
                                    Text(member.username)
                                    Spacer()
                                    if selectedSplit.contains(member.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button("Add Expense") {
                        Task { await addExpense() }
                    }
                    .disabled(title.isEmpty || amount.isEmpty || paidBy.isEmpty || selectedSplit.isEmpty)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(title.isEmpty || amount.isEmpty || paidBy.isEmpty || selectedSplit.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    func addExpense() async {
        guard let amountValue = Double(amount) else { return }
        let splitIDs = Array(selectedSplit)

        let newExpense = Expense(
            groupID: groupID,
            title: title,
            amount: amountValue,
            date: date,
            paidBy: paidBy,
            splitBetween: splitIDs
        )

        do {
            try await GroupExpenseService.shared.addExpense(to: groupID, expense: newExpense)
            dismiss()
        } catch {
            print("Failed to add expense:", error)
        }
    }
}

#Preview {
    AddExpenseView(
        groupID: "group1",
        members: [
            UserProfile(id: "user1", email: "a@example.com", username: "Alice"),
            UserProfile(id: "user2", email: "b@example.com", username: "Bob"),
            UserProfile(id: "user3", email: "c@example.com", username: "Charlie")
        ]
    )
}
