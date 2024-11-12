//
//  LoginView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var networkMonitor = NetworkMonitor() // Connection with network monitoring
    
    
    @State  private var emailGo = false
    @State  private var loginGo = false
    
    var body: some View {
        if networkMonitor.isConnected {
            NavigationStack {
                VStack(spacing: 35) {
                    HStack {
                        Text("Chat")
                            .font(.system(size: 33, weight: .regular))
                            .foregroundColor(.purple)
                        Image("Loggo")
                            .resizable()
                            .frame(width: 150, height: 60)
                    }
                    .offset(y: -20)
                    
                    ZStack {
                        PrimaryButton(
                            title:"Google",
                            action: { viewModel.loginWithGoogle() },
                            mod: false,
                            supportText: "Get started with"
                        )
                        
                        Image("googleLogo")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .offset(x: -50, y: 19)
                    }
                    
                    PrimaryButton(title: "Email", action: { emailGo = true },
                                  mod: true, supportText: "Or sign up with")
                    
                    PrimaryButton(title: "Login", action: { loginGo = true },
                                  mod: false, supportText: "Already onboard?")
                }
                .navigationDestination(isPresented: $emailGo) { SignUpView() }
                .navigationDestination(isPresented: $loginGo) { LoginView() }
                .navigationDestination(isPresented: $viewModel.loginSuccess) { TabBarView() }
                
                .fullScreenCover(isPresented: $viewModel.isShowingGoogleSignIn) {
                    GoogleSignInViewControllerRepresentable { result in
                        viewModel.handleSignInResult(result)
                    }
                }
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("Sign-In Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarBackButtonHidden(true)
        } else {
            NoConnectionView(networkMonitor: networkMonitor)
        }
        
    }
}
    
    #Preview {
        MainView()
    }
