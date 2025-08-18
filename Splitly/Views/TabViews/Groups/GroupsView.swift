//
//  Groups.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-05-06.
//

import SwiftUI

struct GroupsView: View {
    @StateObject private var viewModel = GroupsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.groups.isEmpty {
                    Text("No groups yet!")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List(viewModel.groups) { group in
                        NavigationLink(value: group) {
                            Text(group.name)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.leaveGroup(group)
                                }
                            } label: {
                                Label("Leave", systemImage: "person.fill.xmark")
                            }
                        }
                        
                    }
                    .padding(.top)
                    .navigationDestination(for: ChatGroup.self) { group in
                        GroupDetailView(group: group)
                    }
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                Button("Create") {
                    viewModel.showCreateSheet = true
                }
            }
            .task {
                await viewModel.loadGroups()
            }
            .sheet(isPresented: $viewModel.showCreateSheet) {
                VStack(spacing: 20) {
                    TextField("Group Name", text: $viewModel.newGroupName)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("Select Friends")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    List(viewModel.friends) { friend in
                        Button {
                            if viewModel.selectedFriendIDs.contains(friend.id) {
                                viewModel.selectedFriendIDs.remove(friend.id)
                            } else {
                                viewModel.selectedFriendIDs.insert(friend.id)
                            }
                        } label: {
                            HStack {
                                Text(friend.username)
                                Spacer()
                                if viewModel.selectedFriendIDs.contains(friend.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .task {
                        await viewModel.loadFriends()
                    }
                    
                    Button("Create") {
                        Task { await viewModel.createGroup() }
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    GroupsView()
}
