//
//  ChatView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/10/24.
//

import SwiftUI

struct ChatsViewWrapper: UIViewControllerRepresentable {
    let user: MUser
    let chat: MChat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ChatsViewController {
        let chatsVC = ChatsViewController(user: user, chat: chat)
        // Дополнительная настройка при необходимости
        return chatsVC
    }

    func updateUIViewController(_ uiViewController: ChatsViewController, context: Context) {
        // Обновление контроллера при изменении данных
    }

    class Coordinator: NSObject {
        var parent: ChatsViewWrapper

        init(_ parent: ChatsViewWrapper) {
            self.parent = parent
        }
    }
}
