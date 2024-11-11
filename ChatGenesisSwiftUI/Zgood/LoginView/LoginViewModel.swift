//
//  LoginViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/10/24.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import SwiftUICore

class LoginViewModel: ObservableObject {
//    @StateObject private var viewModel = SignUpViewModel()

    @Published var email = ""
    @Published var password = ""
    
    @Published var logError = ""
    @Published var isShowingGoogleSignIn = false
    @Published var errorMessage: ErrorMessage? // Use ErrorMessage type here
    @Published var loginFals = false // Для отслеживания успешного входа
    @Published var loginSuccess = false // Для отслеживания успешного входа
    
    struct ErrorMessage: Identifiable {
        let id = UUID()
        let message: String
    }
    
    func loginWithGoogle() {
        isShowingGoogleSignIn = true
    }
    
    func handleSignInResult(_ result: Result<User, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let user):
                self.loginSuccess = true
                print("Successfully signed in: \(user.email ?? "No email")")
            case .failure(let error):
                self.errorMessage = ErrorMessage(message: error.localizedDescription)
                print("Failed to sign in: \(error.localizedDescription)")
            }
            self.isShowingGoogleSignIn = false
        }
    }
    
    func login() {
        AuthService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.loginSuccess = true
                    print("Вход выполнен для пользователя: \(user.email ?? "без email")")
                case .failure(let error):
                    self?.errorMessage = ErrorMessage(message: error.localizedDescription)
                    self?.loginFals = true
                    print("Ошибка при входе: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateLogError() {
        if !validateEmail {
            logError = "Invalid email format"
        } else {
            logError = "Wrong email"
        }
    }
     
    var validLog: Bool {
        return !password.isEmpty && validateEmail
    }
    
    var validateEmail: Bool {
        let emailRegEx = #"^(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+)@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"#
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}



