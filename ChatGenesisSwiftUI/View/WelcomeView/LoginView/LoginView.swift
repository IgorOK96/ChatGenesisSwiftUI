//
//  LoginView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isEmailValid = true
    @State  private var emailGo = false
    
    @FocusState private var isFocused: Bool // Focus state for TextField

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
                        action: { viewModel.loginWithGoogle() },
                        mod: false,
                        supportText: "Login with")
                    Image("googleLogo")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .offset(x: -50, y: 19)
                }
                HStack {
                    Text("or")
                        .font(.sansReg(22))
                    Spacer()
                }
                .padding(.leading, 35)
                
                VStack(spacing: 10) {
                    TextFieldView(
                        text: $viewModel.email,
                        isValid: $isEmailValid,
                        placeholder: "Email",
                        errorText: viewModel.logError
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    
                    TextFieldView(
                        text: $viewModel.password,
                        isValid: $isEmailValid,
                        placeholder: "Password",
                        errorText: "Wrong Password"
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                }
                
                PrimaryButton(
                    title:"Login",
                    action:{
                        viewModel.updateLogError()
                        
                        guard viewModel.validLog else { return
                            isEmailValid = viewModel.validLog }
                        
                        viewModel.login()
                        
                        guard viewModel.loginSuccess else { return }
                        isEmailValid = !viewModel.loginSuccess

                    },
                    mod: true)
                    .offset(y: -30)
                
                Spacer()
                
                BottomButton(
                    textSupport: "Need an account?",
                    textButton: "Sign up",
                    action: { emailGo = true })
            }
            .hideKeyboard()
            .navigationDestination(isPresented: $emailGo) { SignUpView() }
            .navigationDestination(isPresented: $viewModel.loginSuccess) { TabBarView() }
            .fullScreenCover(isPresented: $viewModel.isShowingGoogleSignIn) {
                GoogleSignInViewControllerRepresentable { result in
                    viewModel.handleSignInResult(result)
                }
            }
        }
    }
}



