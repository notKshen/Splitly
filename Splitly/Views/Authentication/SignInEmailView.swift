//
//  SignInEmailView.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-06-05.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await AuthManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await AuthManager.shared.signInUser(email: email, password: password)
    }
    
    func createUserDocument(userID: String, email: String, username: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        try await userRef.setData([
            "email": email,
            "username": username.lowercased(),
            "createdAt": Timestamp()
        ])
    }
}

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            TextField("Username...", text: $viewModel.username)
                .padding()
                .background(Color.gray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        if let user = Auth.auth().currentUser {
                            try await viewModel.createUserDocument(
                                userID: user.uid,
                                email: user.email ?? "",
                                username: viewModel.username
                            )
                        }
                        showSignInView = false
                        return
                    } catch {
                        print("Error")
                    }
                    
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print("Error")
                    }
                }
            } label: {
                Text("Sign in with Email")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}
        

#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
    }
}
