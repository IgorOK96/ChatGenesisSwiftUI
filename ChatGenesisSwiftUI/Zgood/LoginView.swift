//
//  LoginView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    @State  private var emailGo = false
    @State  private var chatGo = false
    
    @State private var isNameValid = true
    @State private var isEmailValid = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                Spacer()
                Text("Welcome Back!")
                    .font(.sansReg(35))
                    .foregroundColor(.purpleDark)
                    .offset(y: -20)
                ZStack {
                    PrimaryButton(
                        title:"Google",
                        action: { },
                        mod: false,
                        supportText: "Login with")
                    Image("googleLogo")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .offset(x: -50, y: 16.5)
                }
                HStack {
                    Text("or")
                        .font(.sansReg(22))
                    Spacer()
                }
                .padding(.leading, 35)
                
                VStack(spacing: 10) {
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
                }
                
                PrimaryButton(title:"Login", action: { chatGo = true }, mod: true)
                    .offset(y: -30)
                
                Spacer()
                
                BottomButton(
                    textSupport: "Need an account?",
                    textButton: "Sign up",
                    action: { emailGo = true
                        print("Login >> Sign") })
            }
            .hideKeyboard()
            .navigationDestination(isPresented: $emailGo) { SignUpView() }
            .navigationDestination(isPresented: $chatGo) { TabBarView() }
        }
    }
}


#Preview {
    LoginView()
}
