//
//  PhotoButtom.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct PhotoButtom: View {
    @Binding var selectedImage: UIImage?
    
    @State private var showConfirmationDialog = false
    @State private var showImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Image("plus")
                .resizable()
                .frame(width: 40, height: 40)
            
            Button(action: { showConfirmationDialog = true }) {
                Color.clear // Прозрачный фон, чтобы захватить всю область
                    .frame(width: 45, height: 45)
            }
            .confirmationDialog("Choose how you want to add a photo  \n Size no more 5 Mb",
                                isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                Button("Camera") {
                    imagePickerSourceType = .camera
                    showImagePicker = true
                }
                Button("Gallery") {
                    imagePickerSourceType = .photoLibrary
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(
                    sourceType: imagePickerSourceType,
                    selectedImage: $selectedImage,
                    errorMessage: $errorMessage
                )
            }
        }
    }
}


//#Preview {
//    PhotoButtom()
//}
