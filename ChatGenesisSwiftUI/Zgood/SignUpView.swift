//
//  SingUpView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    @State  private var chatGo = false
    @State  private var loginGo = false
    
    @State private var isNameValid = true
    @State private var isEmailValid = true
    @State private var isPhoneValid = true
    @State private var isPhotoValid = true
    
    @FocusState private var isFocused: Bool // Focus state for TextField
    
    var body: some View {
        NavigationStack {
            VStack() {
                Spacer()
                Text("Igor! Hello!")
                    .font(.sansReg(35))
                    .foregroundColor(.purpleDark)
                    .offset(y: -50)
                
                VStack(spacing: 13) {
                    TextFieldView(
                        text: $viewModel.name,
                        isValid: $isNameValid,
                        placeholder: "Email",
                        errorText: "Required field"
                    )
                    
                    TextFieldView(
                        text: $viewModel.email,
                        isValid: $isEmailValid,
                        placeholder: "Password",
                        errorText: "Invalid email format"
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    
                    TextFieldView(
                        text: $viewModel.phone,
                        isValid: $isPhoneValid,
                        placeholder: "Confirm password",
                        errorText: ""
                    )
                }
                
                PrimaryButton(title: "Sign up", action: {chatGo = true}, mod: true)
                    .offset(y: -10)
                
                Spacer()
                
                BottomButton(
                    textSupport: "Already onboard?",
                    textButton: "Login",
                    action: { loginGo = true
                        print("Sign >> Login")
                    })
            }
            .hideKeyboard()
            .navigationDestination(isPresented: $loginGo) { LoginView() }
            .navigationDestination(isPresented: $chatGo) { SetupProfileView() }
        }
    }
}

#Preview {
    SignUpView()
}
