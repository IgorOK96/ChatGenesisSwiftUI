//
//  ChatViewWrapper.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/10/24.
//

import SwiftUI
import MessageKit
//import FirebaseFirestore

struct ChatViewWrapper: UIViewControllerRepresentable {
    let user: MUser
    let chat: MChat

    func makeUIViewController(context: Context) -> ChatsViewController {
        return ChatsViewController(user: user, chat: chat)
    }

    func updateUIViewController(_ uiViewController: ChatsViewController, context: Context) {
        // Здесь можно добавлять обновление данных, если потребуется.
    }
}

#Preview {
    ChatViewWrapper()
}
