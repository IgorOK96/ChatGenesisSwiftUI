//
//  SetupProfileView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct SetupProfileView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var chatGo = false
    
    @State private var selectedImage: UIImage? //ImagePicker

    @State private var selectedSex = "Male"
        let sexes = ["Male", "Female"]
    
    @State private var isNameValid = true
    @State private var isEmailValid = true
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Set up profile")
                .font(.sansReg(33))
            HStack(spacing: 10) {
                Image(uiImage: selectedImage ?? UIImage(named: "avatar")!)
                    .resizable()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                    .overlay(Circle().stroke( selectedImage != nil ? Color.orange : Color.purpleLite, lineWidth: 4)) // Обводка
                    
                PhotoButtom(selectedImage: $selectedImage)
            }
            .offset(x: 25, y: -20)
            
            VStack(spacing: 13) {
                TextFieldView(
                    text: $viewModel.name,
                    isValid: $isNameValid,
                    placeholder: "Full Name",
                    errorText: "Required field"
                )
                
                TextFieldView(
                    text: $viewModel.email,
                    isValid: $isEmailValid,
                    placeholder: "About me",
                    errorText: "Wtf"
                )
                
                PickerCustom(selectedSegment: $viewModel.selectedSex) // Передаем selectedSex как Binding

                PrimaryButton(title: "Go to chats!", action: {chatGo = true}, mod: true)
            }
            .navigationDestination(isPresented: $chatGo) { TabBarView() }
        }
        .hideKeyboard()
    }
}

#Preview {
    SetupProfileView()
}
