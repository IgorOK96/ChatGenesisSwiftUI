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
    @Published var filteredChats: [MChat] = []  // Отфильтрованные чаты
    @Published var searchText: String = ""      // Текст для поиска

    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    private var activeChatsRef: CollectionReference {
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("activeChats")
    }

    init() {
        fetchActiveChats()
        setupSearchPublisher()
    }

    // Метод для настройки поиска
    private func setupSearchPublisher() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest($activeChats)
            .map { (searchText, chats) -> [MChat] in
                guard !searchText.isEmpty else {
                    return chats
                }
                return chats.filter { chat in
                    chat.friendUsername.localizedCaseInsensitiveContains(searchText)
                }
            }
            .assign(to: &$filteredChats)
    }

    // Метод для получения активных чатов
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

    private func activeChatsPublisher() -> AnyPublisher<[MUser], Never> {
        let subject = PassthroughSubject<[MUser], Never>()

        activeChatsRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Ошибка получения активных чатов: \(error.localizedDescription)")
                subject.send([])
            } else {
                let chats = querySnapshot?.documents.compactMap { MUser(document: $0) } ?? []
                subject.send(chats)
                
                // Загружаем изображения для чатов после каждого обновления
                self.loadImagesForActiveChats()
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
