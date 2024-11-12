//
//  SetupProfileView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct SetupProfileView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    @State private var isNameValid = true
    @State private var isBioValid = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Set up profile")
                    .font(.sansReg(33))
                HStack(spacing: 10) {
                    Image(uiImage: viewModel.avatarImage ?? UIImage(named: "avatar")!)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .overlay(Circle().stroke( viewModel.avatarImage != nil ? Color.orange : Color.purpleLite, lineWidth: 4)) // Обводка
                    
                    PhotoButtom(selectedImage: $viewModel.avatarImage)
                }
                .offset(x: 25, y: -20)
                
                VStack(spacing: 13) {
                    TextFieldView(
                        text: $viewModel.username,
                        isValid: $isNameValid,
                        placeholder: "Full Name",
                        errorText: "Required field"
                    )
                    
                    TextFieldView(
                        text: $viewModel.description,
                        isValid: $isBioValid,
                        placeholder: "About me",
                        errorText: "Wtf"
                    )
    
                    
                    PickerCustom(selectedSegment: $viewModel.selectedSex) // Передаем selectedSex как Binding
                    
                    PrimaryButton(
                        title: "Go to chats!",
                        action: {
                            isNameValid = viewModel.validName
                            isBioValid = viewModel.validBio
                            if viewModel.profileValid  {
                                viewModel.saveUserProfile() }
                        },
                        mod: true)
                }
                .fullScreenCover(isPresented: $viewModel.isProfileSaved) {
                    TabBarView()
                }
            }
            .hideKeyboard()
        }
    }
}


struct SetupProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Создаем экземпляр SignUpViewModel с тестовыми данными
        let previewViewModel = SignUpViewModel()
        previewViewModel.username = "Preview User"
        previewViewModel.description = "This is a preview description."
        previewViewModel.selectedSex = 0 // Например, "Male"
        previewViewModel.avatarImage = UIImage(named: "avatar") // Убедитесь, что такой ресурс существует
        
        return SetupProfileView(viewModel: previewViewModel)
    }
}
