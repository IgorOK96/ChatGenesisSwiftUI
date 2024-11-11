//
//  SingUpView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var isEmailValid = true
    @State private var isPassword = true
    
    @State  private var loginGo = false

    @FocusState private var isFocused: Bool // Focus state for TextField
    
    var body: some View {
        NavigationStack {
            VStack() {
                Spacer()
                Text("Hello! My Bro!")
                    .font(.sansReg(35))
                    .foregroundColor(.purpleDark)
                    .offset(y: -50)
                
                VStack(spacing: 13) {
                    TextFieldView(
                        text: $viewModel.email,
                        isValid: $isEmailValid,
                        placeholder: "Email",
                        errorText: "Invalid email format"
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    
                    TextFieldView(
                        text: $viewModel.password,
                        isValid: $isPassword,
                        placeholder: "Password",
                        errorText: "The passwords don't match"
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    
                    TextFieldView(
                        text: $viewModel.confirmPassword,
                        isValid: $isPassword,
                        placeholder: "Confirm password",
                        errorText: "The passwords don't match"
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                }
                PrimaryButton(
                    title: "Sign up",
                    action: {
                        isEmailValid = viewModel.validateEmail
                        isPassword = viewModel.isPasswordValid
                        if viewModel.isFormValid  {viewModel.registerEmail()}
                    },
                    mod: true)
                    .offset(y: -10)
                
                Spacer()
                
                BottomButton(
                    textSupport: "Already onboard?",
                    textButton: "Login",
                    action: { loginGo = true
                    })
            }
            .hideKeyboard()
            .navigationDestination(isPresented: $viewModel.registrationSuccess) { SetupProfileView() }
            .navigationDestination(isPresented: $loginGo) { LoginView() }
        }
    }
}

#Preview {
    SignUpView()
}
