//
//  ActiveChatsView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/11/24.
//

import SwiftUI

struct RequestListView: View {
    @ObservedObject var chatVM: ChatsListViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(chatVM.filteredWait, id: \.friendId) { chat in
                    if let image = chatVM.waitActiveImages[chat.friendId] {
                        NavigationLink(
                            destination: RequestView(
                                imageAv: image,
                                name: chat.friendUsername,
                                chat: chat
                            )
                        ) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 90, height: 90)
                                .shadow(radius: 5)
                                .cornerRadius(5)
                        }
                    } else {
                        // Placeholder пока изображение загружается
                        Image(systemName: "avatar")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .shadow(radius: 5)
                            .cornerRadius(5)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}



