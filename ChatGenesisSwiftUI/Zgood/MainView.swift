//
//  LoginView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct MainView: View {
    @State  private var emailGo = false
    @State  private var loginGo = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 35) {
                HStack {
                    Text("Chat ")
                        .font(.sansReg(33))
                        .foregroundColor(.purpleDark)
                    Image("Loggo")
                        .resizable()
                        .frame(width: 150, height: 60)
                }
                .offset(y: -20)
                ZStack {
                    PrimaryButton(title:"Google", action: {}, mod: false, supportText: "Get started with")
                    Image("googleLogo")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .offset(x: -50, y: 16.5)
                }
                PrimaryButton(title: "Email", action: { emailGo = true }
                              , mod: true, supportText: "Or sign up with")
                
                PrimaryButton(title: "Login", action: { loginGo = true }
                              , mod: false, supportText: "Already onboard?")
            }
            .navigationDestination(isPresented: $emailGo) { SignUpView() }
            
            .navigationDestination(isPresented: $loginGo) { LoginView() }

        }
    }
}


#Preview {
    MainView()
}
