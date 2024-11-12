//
//  RequestView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct RequestView: View {
    @ObservedObject var requestListVM: RequestListViewModel
    let imageAv: UIImage
    let name: String
    let chat: MChat
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(uiImage: imageAv)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(alignment: .leading ,spacing: 20) {
                Text(name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("You have the opportunity to start a new chat")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    ChatAcceptButton(
                        colorOne: .orange,
                        colorTwo: .purple,
                        title: "ACCEPT",
                        action: {
                            requestListVM.acceptRequest(chat: chat)
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    
                    ChatAcceptButton(
                        colorOne: .red,
                        colorTwo: .black,
                        title: "DENY",
                        action: {
                            requestListVM.declineRequest(chat: chat)
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
                .padding(.horizontal, 20)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width - 40)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
        }
    }
}


struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView(
            requestListVM: RequestListViewModel(),
            imageAv: UIImage(systemName: "person.circle")!,
            name: "John Doe",
            chat: MChat(friendUsername: "John", friendAvatarStringURL: "http://example.com/avatar.jpg", friendId: "Hello!", lastMessageContent: "123")
        )
    }
}
