//
//  GroupExpenseService.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-08-15.
//

import FirebaseAuth
import FirebaseFirestore

@MainActor
final class GroupExpenseService {
    static let shared = GroupExpenseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func addExpense(to groupId: String, expense: Expense) async throws {
        try await db.collection("groups")
            .document(groupId)
            .collection("expenses")
            .document(expense.id)
            .setData([
                "title": expense.title,
                "amount": expense.amount,
                "date": Timestamp(date: expense.date),
                "paidBy": expense.paidBy,
                "splitBetween": expense.splitBetween
            ])
    }
    
    func fetchExpenses(for groupID: String) async throws -> [Expense] {
        let snapshot = try await db.collection("groups")
            .document(groupID)
            .collection("expenses")
            .order(by: "date", descending: true)
            .getDocuments()
        
        var expenses: [Expense] = []
        
        for doc in snapshot.documents {
            let data = doc.data()
            guard let title = data["title"] as? String,
                  let amount = data["amount"] as? Double,
                  let timestamp = data["date"] as? Timestamp,
                  let paidBy = data["paidBy"] as? String,
                  let splitBetween = data["splitBetween"] as? [String] else {
                continue // skip invalid document
            }
            
            let expense = Expense(
                id: doc.documentID,
                groupID: groupID,
                title: title,
                amount: amount,
                date: timestamp.dateValue(),
                paidBy: paidBy,
                splitBetween: splitBetween
            )
            expenses.append(expense)
        }
        
        return expenses
    }

}
