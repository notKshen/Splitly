//
//  GroupService.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-08-13.
//

import FirebaseFirestore
import FirebaseAuth

@MainActor
final class GroupService {
    static let shared = GroupService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func createGroup(name: String, memberIDs: [String]) async throws {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        var members = [currentUserID] + memberIDs
        
        members = Array(Set(members))
        
        let groupRef = db.collection("groups").document()
        try await groupRef.setData([
            "name": name,
            "members": members,
            "createdAt": Timestamp()
        ])
    }

    
    func fetchGroups() async throws -> [ChatGroup] {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await Firestore.firestore()
            .collection("groups")
            .whereField("members", arrayContains: currentUserId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let name = data["name"] as? String,
                  let members = data["members"] as? [String],
                  let timestamp = data["createdAt"] as? Timestamp else {
                return nil
            }
            
            let createdAt = timestamp.dateValue()
            return ChatGroup(id: doc.documentID, name: name, memberIDs: members, createdAt: createdAt)
        }
    }
}
