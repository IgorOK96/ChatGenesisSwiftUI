//
//  RequestListView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/11/24.
//

import SwiftUI

import SwiftUI

struct ActiveChatsListView: View {
        @ObservedObject var activeChatsVM: ActiveChatsListViewModel
    
        let currentUser: MUser?

        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(activeChatsVM.activeChats, id: \.friendId) { chat in
                        HStack {
                            if let image = activeChatsVM.activeChatImages[chat.friendId] {
                                if let user = currentUser {
                                    NavigationLink(
                                        destination: ChatView(user: user, chat: chat)
                                    ) {
                                        HStack {
                                            Image(uiImage: image)
                                                .resizable()
                                                .frame(width: 80, height: 80)
                                                .shadow(radius: 5)
                                                .cornerRadius(5)

                                            VStack(alignment: .leading, spacing: 15) {
                                                Text(chat.friendUsername)
                                                    .font(.system(size: 18))
                                                Text(chat.lastMessageContent)
                                                    .font(.system(size: 16))
                                            }
                                            Spacer()
                                        }
                                    }
                                } else {
                                    Text("Загрузка...")
                                }
                            } else {
                                // Placeholder пока изображение загружается
                                HStack {
                                    Image(systemName: "person.crop.square")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .shadow(radius: 5)
                                        .cornerRadius(5)

                                    VStack(alignment: .leading, spacing: 15) {
                                        Text(chat.friendUsername)
                                            .font(.system(size: 18))
                                        Text(chat.lastMessageContent)
                                            .font(.system(size: 16))
                                    }
                                    Spacer()
                                }
                            }

                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [.orange, .purple]
                                        ),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 15, height: 80)
                                .cornerRadius(20)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

//#Preview {
//    RequestListView()
//}
