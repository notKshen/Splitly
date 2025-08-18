//
//  GroupsViewModel.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-08-13.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class GroupsViewModel: ObservableObject {
    @Published var groups: [ChatGroup] = []
    @Published var showCreateSheet = false
    @Published var newGroupName = ""
    @Published var friends: [UserProfile] = []
    @Published var selectedFriendIDs: Set<String> = []
    
    private let db = Firestore.firestore()
    
    func loadGroups() async {
        do {
            groups = try await GroupService.shared.fetchGroups()
        } catch {
            print("Failed to fetch groups:", error)
            groups = []
        }
    }
    
    func loadFriends() async {
        do {
            friends = try await ProfileViewModel().fetchFriendsForGroups()
        } catch {
            print("Failed to load friends:", error)
            friends = []
        }
    }
    
    func createGroup() async {
        guard !newGroupName.isEmpty else { return }
        do {
            let currentUserID = Auth.auth().currentUser?.uid ?? ""
            let allMemberIDs = selectedFriendIDs.union([currentUserID])
            
            try await GroupService.shared.createGroup(name: newGroupName, memberIDs: Array(allMemberIDs))
            
            // Reset sheet
            newGroupName = ""
            selectedFriendIDs = []
            showCreateSheet = false
            
            await loadGroups()
        } catch {
            print("Failed to create group:", error)
        }
    }
    
    func leaveGroup(_ group: ChatGroup) async {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let groupRef = db.collection("groups").document(group.id)
        
        do {
            // Remove user from group
            try await groupRef.updateData([
                "members": FieldValue.arrayRemove([currentUserID])
            ])
            
            // Auto-delete if empty
            let snapshot = try await groupRef.getDocument()
            if let members = snapshot.get("members") as? [String], members.isEmpty {
                try await groupRef.delete()
            }
            
            // Refresh local groups
            await loadGroups()
        } catch {
            print("Error leaving group: \(error)")
        }
    }
}
