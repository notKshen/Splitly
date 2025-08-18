//
//  GroupDetailView.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-08-15.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GroupDetailView: View {
    let group: ChatGroup
    @State private var members: [UserProfile] = []
    @State private var expenses: [Expense] = []
    @State private var netDebts: [String: Double] = [:]
    @State private var showAddExpense = false
    
    // Listener
    @State private var expensesListener: ListenerRegistration?

    var body: some View {
        VStack(spacing: 20) {
            Text(group.name)
                .font(.largeTitle)
                .bold()
            
            // Members
            Text("Members")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            List(members) { member in
                VStack(alignment: .leading) {
                    Text(member.username)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 150)
            
            // Debts Summary
            if !netDebts.isEmpty {
                Text("Debts")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                List(sortedDebts(), id: \.0) { debtor, creditor, amount in
                    Text("\(debtor) owes \(creditor): $\(amount, specifier: "%.2f")")
                }
                .frame(height: 150)
            }
            
            // Add Expense
            Button("Add Expense") {
                showAddExpense = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Expense List
            List(expenses) { expense in
                VStack(alignment: .leading) {
                    Text(expense.title)
                    Text("Paid by: \(username(for: expense.paidBy)) • $\(expense.amount, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .task {
            await loadMembers()
            startListeningForExpenses()
        }
        .onDisappear {
            // Stop listener when view disappears
            expensesListener?.remove()
        }
        .sheet(isPresented: $showAddExpense, onDismiss: {
            // Expenses auto-refresh via listener
        }) {
            AddExpenseView(groupID: group.id, members: members)
        }
    }
    
    // Load Members
    func loadMembers() async {
        var fetched: [UserProfile] = []
        for id in group.memberIDs {
            if let doc = try? await Firestore.firestore()
                .collection("users")
                .document(id)
                .getDocument(),
               let data = doc.data(),
               let username = data["username"] as? String,
               let email = data["email"] as? String {
                fetched.append(UserProfile(id: id, email: email, username: username))
            }
        }
        members = fetched
    }
    
    // Real-Time Expenses Listener
    func startListeningForExpenses() {
        let db = Firestore.firestore()
        expensesListener = db.collection("groups")
            .document(group.id)
            .collection("expenses")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Failed to listen for expenses:", error)
                    expenses = []
                    netDebts = [:]
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    expenses = []
                    netDebts = [:]
                    return
                }
                
                let newExpenses: [Expense] = docs.compactMap { doc -> Expense? in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let amount = data["amount"] as? Double,
                          let timestamp = data["date"] as? Timestamp,
                          let paidBy = data["paidBy"] as? String,
                          let splitBetween = data["splitBetween"] as? [String] else {
                        return nil
                    }
                    
                    return Expense(
                        id: doc.documentID,
                        groupID: group.id,
                        title: title,
                        amount: amount,
                        date: timestamp.dateValue(),
                        paidBy: paidBy,
                        splitBetween: splitBetween
                    )
                }
                
                expenses = newExpenses
                netDebts = calculateNetDebts(from: expenses)
            }
    }
    
    // Helper: Map userID -> username
    func username(for id: String) -> String {
        members.first(where: { $0.id == id })?.username ?? id
    }
    
    // Helper: Sorted debts with usernames
    func sortedDebts() -> [(String, String, Double)] {
        netDebts.compactMap { key, value in
            let parts = key.split(separator: "->").map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { return nil }
            return (username(for: String(parts[0])), username(for: String(parts[1])), value)
        }
        .sorted { $0.0 < $1.0 }
    }
}

#Preview {
    GroupDetailView(group: ChatGroup(
        id: "group1",
        name: "Trip to Japan",
        memberIDs: ["user1", "user2", "user3"],
        createdAt: Date()
    ))
}
