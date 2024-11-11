//
//  AuthService.swift
//  IChat
//
//  Created by Алексей Пархоменко on 30.01.2020.
//  Copyright © 2020 Алексей Пархоменко. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthService {
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    
    // Получить uid текущего пользователя
    var currentUserUID: String? {
        return auth.currentUser?.uid
    }
    
    // Получить email текущего пользователя
    var currentUserEmail: String? {
        return auth.currentUser?.email
    }
    
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void) {
        
        guard let email = email, let password = password else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        auth.signIn(withEmail: email, password: password) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase clientID is nil")
            return
        }
        print("Firebase clientID: \(clientID)")
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        print("Google Sign-In configuration set")
        
        // Start the sign-in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            print("Entered signIn completion handler")
            
            if let error = error {
                print("Error during Google Sign-In: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Failed to get authentication token.")
                completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get authentication token."])))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            self.auth.signIn(with: credential) { authResult, error in
                print("Firebase auth completion handler")
                if let error = error {
                    print("Error during Firebase auth: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let user = authResult?.user {
                    print("Successfully signed in with Firebase")
                    completion(.success(user))
                } else {
                    print("User not found in Firebase")
                    completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
                }
            }
        }
    }
    
    // Функция регистрации
    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить пользователя"])))
                return
            }
            completion(.success(user))
        }
    }
    
}


    




