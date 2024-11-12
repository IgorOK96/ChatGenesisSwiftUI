//
//  ss.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/11/24.
//

import Combine
import FirebaseFirestore
import FirebaseAuth
import UIKit

class RequestListViewModel: ObservableObject {
    @Published var waitingChats: [MChat] = []
    @Published var waitingChatImages: [String: UIImage] = [:]

    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    private var waitingChatsRef: CollectionReference {
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("waitingChats")
    }

    init() {
        fetchWaitingChats()
    }

    // Метод для принятия чата
    func acceptRequest(chat: MChat) {
        changeToActivePublisher(chat: chat)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Ошибка принятия чата: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] in
                self?.waitingChats.removeAll { $0.friendId == chat.friendId }
                self?.waitingChatImages.removeValue(forKey: chat.friendId)
            })
            .store(in: &cancellables)
    }

    // Метод для удаления чата
    func declineRequest(chat: MChat) {
        deleteWaitingChatPublisher(chat: chat)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Ошибка удаления чата: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] in
                self?.waitingChats.removeAll { $0.friendId == chat.friendId }
                self?.waitingChatImages.removeValue(forKey: chat.friendId)
            })
            .store(in: &cancellables)
    }

    // Перевод чата в активный (Publisher)
    private func changeToActivePublisher(chat: MChat) -> AnyPublisher<Void, Error> {
        getWaitingChatMessagesPublisher(chat: chat)
            .flatMap { messages in
                self.deleteWaitingChatPublisher(chat: chat)
                    .flatMap { _ in
                        self.createActiveChatPublisher(chat: chat, messages: messages)
                    }
            }
            .eraseToAnyPublisher()
    }

    // Получение сообщений из ожидающего чата (Publisher)
    private func getWaitingChatMessagesPublisher(chat: MChat) -> AnyPublisher<[MMessage], Error> {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")

        return Future<[MMessage], Error> { promise in
            reference.getDocuments { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let messages = querySnapshot?.documents.compactMap { MMessage(document: $0) } ?? []
                    promise(.success(messages))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // Удаление ожидающего чата (Publisher)
    private func deleteWaitingChatPublisher(chat: MChat) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.waitingChatsRef.document(chat.friendId).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // Создание активного чата (Publisher)
    private func createActiveChatPublisher(chat: MChat, messages: [MMessage]) -> AnyPublisher<Void, Error> {
        let activeChatsRef = db.collection("users").document(Auth.auth().currentUser!.uid).collection("activeChats")
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")

        return Future<Void, Error> { promise in
            activeChatsRef.document(chat.friendId).setData(chat.representation) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                let batch = self.db.batch()
                for message in messages {
                    guard let messageID = message.id else {
                        continue
                    }
                    let messageDocument = messageRef.document(messageID)
                    batch.setData(message.representation, forDocument: messageDocument)
                }

                batch.commit { batchError in
                    if let batchError = batchError {
                        promise(.failure(batchError))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // Метод для получения ожидающих чатов с использованием Combine
    func fetchWaitingChats() {
        waitingChatsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chats in
                self?.waitingChats = chats
                self?.loadImagesForWaitingChats()
            }
            .store(in: &cancellables)
    }

    private func waitingChatsPublisher() -> AnyPublisher<[MChat], Never> {
        let subject = PassthroughSubject<[MChat], Never>()

        waitingChatsRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Ошибка получения ожидающих чатов: \(error.localizedDescription)")
                subject.send([])
            } else {
                let chats = querySnapshot?.documents.compactMap { MChat(document: $0) } ?? []
                subject.send(chats)
            }
        }

        return subject.eraseToAnyPublisher()
    }

    // Методы для загрузки изображений ожидающих чатов
    private func loadImagesForWaitingChats() {
        for chat in waitingChats {
            if waitingChatImages[chat.friendId] == nil {
                loadImage(for: chat)
            }
        }
    }

    private func loadImage(for chat: MChat) {
        guard let url = URL(string: chat.friendAvatarStringURL) else {
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                if let image = image {
                    self?.waitingChatImages[chat.friendId] = image
                }
            }
            .store(in: &cancellables)
    }
}
