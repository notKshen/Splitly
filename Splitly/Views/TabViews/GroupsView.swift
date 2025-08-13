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
                    List(viewModel.groups) { groups in
                        Text(groups.name)
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
