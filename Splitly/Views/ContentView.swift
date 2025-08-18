//
//  ContentView.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-06.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var expenses: [Expense] = []
    @State private var showAddExpense = false
    @State private var selectedGroup: ChatGroup? = nil
    @State private var groupMembers: [UserProfile] = []

    @Binding var showSignInView: Bool

    var body: some View {
        TabView {
            // Groups tab
            GroupsView()
                .tabItem { Label("Groups", systemImage: "person.2") }

            // Profile tab
            ProfileView(showSignInView: $showSignInView)
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }

    func fetchMembers(for group: ChatGroup) async -> [UserProfile] {
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
        return fetched
    }
}


#Preview {
    ContentView(showSignInView: .constant(false))
}


