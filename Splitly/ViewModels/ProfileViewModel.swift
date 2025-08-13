//
//  ProfileViewModel.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-08-13.
//

import FirebaseFirestore
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var results: [UserProfile] = []
    @Published var friends: [UserProfile] = []
    @Published var isLoading = false
    
    func signOut() throws{
         try AuthManager.shared.signOut()
    }
    
    // Friends
    func searchUser(byUsername username: String) async {
        guard !username.isEmpty else { return }
        isLoading = true
        do {
            results = try await UserService.shared.searchUser(byUsername: username)
        } catch {
            print("Search error:", error)
            results = []
        }
        isLoading = false
    }
    func addFriend(friendID: String, username: String, email: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let friendRef = Firestore.firestore()
            .collection("users")
            .document(currentUserId)
            .collection("friends")
            .document(friendID)
        
        try await friendRef.setData([
            "username": username,
            "email": email,
            "addedAt": Timestamp()
        ])
        try await fetchFriends()
    }

    func fetchFriends() async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(currentUserId)
            .collection("friends")
            .getDocuments()
        
        friends = snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let username = data["username"] as? String,
                  let email = data["email"] as? String else { return nil }
            return UserProfile(id: doc.documentID, email: email, username: username)
        }
    }
}

