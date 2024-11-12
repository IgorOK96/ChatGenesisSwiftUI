//
//  GoogleSignInViewControllerRepresentable.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/10/24.
//

import SwiftUI
import UIKit
import FirebaseAuth

struct GoogleSignInViewControllerRepresentable: UIViewControllerRepresentable {
    let onSignIn: (Result<User, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            print("Starting Google Sign-In process")
            AuthService.shared.signInWithGoogle(presentingViewController: viewController) { result in
                print("Google Sign-In result received")
                onSignIn(result)
            }
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No need to update anything here
    }
}

//#Preview {
//    GoogleSignInViewControllerRepresentable()
//}
