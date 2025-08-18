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
    @State private var showSearchResults = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = viewModel.currentUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.secondary)
                    VStack(alignment: .center) {
                        Text(user.username)
                            .font(.title2)
                            .bold()
                        Text(user.email)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                // Search Field
                TextField("Search by username...", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Search") {
                    Task {
                        await viewModel.searchUser(byUsername: searchText)
                        if !viewModel.results.isEmpty {
                            showSearchResults = true
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                // Friends List
                if !viewModel.friends.isEmpty {
                    Text("Friends")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    List {
                        ForEach(viewModel.friends) { friend in
                            VStack(alignment: .leading) {
                                Text(friend.username)
                                    .font(.subheadline)
                                Text(friend.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            let idsToDelete = indexSet.map { viewModel.friends[$0].id }
                            Task {
                                await viewModel.deleteFriends(friendIDs: idsToDelete)
                            }
                        }
                    }
                    .frame(height: 200)
                } else {
                    Text("No friends yet!")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Log Out
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
                .padding(.bottom, 30)
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Profile")
            .onAppear {
                Task {
                    do {
                        try await viewModel.fetchCurrentUser()
                        try await viewModel.fetchFriends()
                    } catch {
                        print("Current User Error \(error)")
                    }
                }
            }
            .sheet(isPresented: $showSearchResults, onDismiss: {
                viewModel.results = [] 
            }) {
                NavigationStack {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Search Results")
                                .font(.headline)
                            Spacer()
                            Button("Close") {
                                showSearchResults = false
                            }
                        }
                        .padding()
                        
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
                                        showSearchResults = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
