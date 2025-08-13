//
//  RootView.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-06-05.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    ContentView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear {
            let authuser = try? AuthManager.shared.getAuthenticatedUser()
            self.showSignInView = authuser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
