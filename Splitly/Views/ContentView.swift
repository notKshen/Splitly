//
//  ContentView.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-06.
//

import SwiftUI

struct ContentView: View {
    @State private var expenses: [Expense] = []
    @State private var showAddExpense = false
    
    var body: some View {
        ZStack {
            TabView() {
                Tab("", systemImage: "house") { Home(expenses: $expenses)}
                Tab("", systemImage: "person.2") { Groups()}
                Tab() {}
                Tab("", systemImage: "arrow.left.arrow.right") { Debts(expenses: $expenses)}
                Tab("", systemImage: "person") { Profile()}
            }
            .tint(.white)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddExpense = true
                    }) {
                        Image(systemName: "plus")
                            .bold()
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(Circle()
                                .fill(Color.gray)
                                .opacity(0.7))
                    }
                    .offset(y: 0)
                    .frame(width: UIScreen.main.bounds.width, alignment: .center)
                }
                .padding(.bottom, 7)
            }
        }
        .fullScreenCover(isPresented: $showAddExpense) {
            AddExpense(expenses: $expenses)
        }
    }
}

#Preview {
    ContentView()
}
