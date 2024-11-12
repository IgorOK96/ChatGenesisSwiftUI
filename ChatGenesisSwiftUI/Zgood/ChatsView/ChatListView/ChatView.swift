//
//  ChatView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/12/24.
//

import SwiftUI

import SwiftUI

struct ChatView: View {
    let chat: MChat
    let image: UIImage

    var body: some View {
        VStack {
            HStack {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                Text(chat.friendUsername)
                    .font(.title)
                Spacer()
            }
            .padding()

            Divider()

            // Здесь можно добавить логику для отображения сообщений чата
            Text("Чат с \(chat.friendUsername)")
                .font(.headline)
                .padding()
            Text("Вот смс >> \(chat.lastMessageContent)")

            Spacer()
        }
        .navigationBarTitle(Text(chat.friendUsername), displayMode: .inline)
    }
}

//#Preview {
//    ChatView()
//}
