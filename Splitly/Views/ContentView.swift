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
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            TabView() {
                Tab("", systemImage: "house") { HomeView(expenses: $expenses)}
                Tab("", systemImage: "person.2") { GroupsView()}
                Tab() {}
                Tab("", systemImage: "arrow.left.arrow.right") { DebtsView(expenses: $expenses)}
                Tab("", systemImage: "person") {
                    ProfileView(showSignInView: $showSignInView)}
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
            AddExpenseView(expenses: $expenses)
        }
    }
}

#Preview {
    ContentView()
}
