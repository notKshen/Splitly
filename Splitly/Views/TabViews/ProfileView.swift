//
//  SettingsView.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-06-05.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // MARK: Search Field
                TextField("Search by username...", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Search") {
                    Task {
                        await viewModel.searchUser(byUsername: searchText)
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                // MARK: Search Results
                if !viewModel.results.isEmpty {
                    Text("Search Results")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    List(viewModel.results) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.username)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Add") {
                                Task {
                                    try await viewModel.addFriend(friendID: user.id, username: user.username, email: user.email)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                }
                
                // MARK: Friends List
                if !viewModel.friends.isEmpty {
                    Text("Your Friends")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    List(viewModel.friends) { friend in
                        VStack(alignment: .leading) {
                            Text(friend.username)
                            Text(friend.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text("No friends yet!")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // MARK: Log Out
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding()
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Profile")
            .onAppear {
                Task { try await viewModel.fetchFriends() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
