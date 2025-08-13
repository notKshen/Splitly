//
//  UserService.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-08-06.
//

import FirebaseFirestore

struct UserProfile: Identifiable {
    let id: String
    let email: String
    let username: String
}

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    func searchUser(byUsername username: String) async throws -> [UserProfile] {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let email = data["email"] as? String,
                  let username = data["username"] as? String else { return nil }
            return UserProfile(id: doc.documentID, email: email, username: username)
        }
    }
    
}
