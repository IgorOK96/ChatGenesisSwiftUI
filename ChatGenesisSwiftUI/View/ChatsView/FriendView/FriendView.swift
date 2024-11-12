//
//  FriendView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/10/24.
//

import SwiftUI

struct FriendView: View {
    @StateObject private var friendVM: FriendViewModel
    let image: UIImage
    let name: String
    @State var valid = true
    
    init(user: MUser, image: UIImage) {
        _friendVM = StateObject(wrappedValue: FriendViewModel(user: user))
        self.image = image
        self.name = user.username
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text(name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("You have the opportunity to start a new chat")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                HStack(spacing: 10) {
                    TextFieldView(
                        text: $friendVM.messageText,
                        isValid: $valid,
                        placeholder: "Your First Message!",
                        errorText: "",
                        padding: 10
                    )
                    
                    Button(action: friendVM.sendMessage) {
                        Image("Sent")
                            .resizable()
                            .frame(width: 35, height: 35)
                    }
                    .offset(x: -5, y: -9)
                }
                .padding(.vertical, 10)
            }
            .padding()
            .frame(width: CGFloat.widthScreen * 2 + 20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .hideKeyboard()
        .alert(item: $friendVM.alertMessage) { alert in
            Alert(title: Text("Уведомление"), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
    }
}

