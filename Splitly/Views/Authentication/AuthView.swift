//
//  AuthView.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-06-05.
//

import SwiftUI

struct AuthView: View {
    @Binding var showSignInView: Bool
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView)
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
            .navigationTitle("Sign In")
        }
    }
}

#Preview {
    NavigationStack {
        AuthView(showSignInView: .constant(false))
    }
}
