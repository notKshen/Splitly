//
//  GroupsViewModel.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-08-13.
//

import SwiftUI

@MainActor
final class GroupsViewModel: ObservableObject {
    @Published var groups: [ChatGroup] = []
    @Published var showCreateSheet = false
    @Published var newGroupName = ""
    
    func loadGroups() async {
        do {
            groups = try await GroupService.shared.fetchGroups()
        } catch {
            print("Failed to fetch groups:", error)
            groups = []
        }
    }
    func createGroup() async {
        do {
            try await GroupService.shared.createGroup(name: newGroupName, memberIDs: [])
            newGroupName = ""
            showCreateSheet = false
            await loadGroups()
        } catch {
            print("Failed to create group:", error)
        }
    }
}
