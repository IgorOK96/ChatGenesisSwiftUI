//
//  ChatListViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/11/24.
//

import Combine
import FirebaseFirestore
import FirebaseAuth
import UIKit

class ActiveChatsListViewModel: ObservableObject {
    @Published var activeChats: [MChat] = []
    @Published var activeChatImages: [String: UIImage] = [:]

    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    private var activeChatsRef: CollectionReference {
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("activeChats")
    }

    init() {
        fetchActiveChats()
    }

    // Метод для получения активных чатов с использованием Combine
    func fetchActiveChats() {
        activeChatsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chats in
                self?.activeChats = chats
                self?.loadImagesForActiveChats()
            }
            .store(in: &cancellables)
    }

    private func activeChatsPublisher() -> AnyPublisher<[MChat], Never> {
        let subject = PassthroughSubject<[MChat], Never>()

        activeChatsRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Ошибка получения активных чатов: \(error.localizedDescription)")
                subject.send([])
            } else {
                let chats = querySnapshot?.documents.compactMap { MChat(document: $0) } ?? []
                subject.send(chats)
            }
        }

        return subject.eraseToAnyPublisher()
    }

    // Методы для загрузки изображений активных чатов
    private func loadImagesForActiveChats() {
        for chat in activeChats {
            if activeChatImages[chat.friendId] == nil {
                loadImageForActiveChat(chat: chat)
            }
        }
    }

    private func loadImageForActiveChat(chat: MChat) {
        guard let url = URL(string: chat.friendAvatarStringURL) else {
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                if let image = image {
                    self?.activeChatImages[chat.friendId] = image
                }
            }
            .store(in: &cancellables)
    }
}
