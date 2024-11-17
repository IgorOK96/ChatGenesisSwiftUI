//
//  ConversationsView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct ChatListView: View {
    @ObservedObject var userVM : SignUpViewModel
    @StateObject private var chatListVM = ChatsListViewModel()

    @FocusState private var isFocused: Bool
    @State var isNew = false
    @State var setting = false

    
    var body: some View {
        NavigationStack {
            HStack {
                SearchControllerBar(searchText: $chatListVM.searchText)
                    .focused($isFocused)
                Button(action: {
                    setting = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .foregroundColor(.purpleLite)
                        .frame(width: 29, height: 29)
                        .offset(x: -15, y:  5)
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Text( "\(chatListVM.waitingChats.count) chats confirmation waiting")
                    .font(.sansReg(25))
                    .padding(.horizontal, 20)
                
                RequestListView(chatVM: chatListVM)
                
                Rectangle()
                    .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    .frame(maxWidth: .infinity) // Расширение по ширине экрана
                    .frame(height: 30)
                
                VStack(alignment: .leading) {
                    Text("Messages")
                        .font(.sansReg(33))
                        .padding(.horizontal, 20)
                    
                    ActiveChatsListView(activeChatsVM: chatListVM, currentUser: userVM.currentUser)
                }
            }
            .sheet(isPresented: $setting) {
                SetupProfileView(viewModel: userVM) // Передаем уже загруженный ViewModel
            }
            .hideKeyboard()
        }
    }
}


