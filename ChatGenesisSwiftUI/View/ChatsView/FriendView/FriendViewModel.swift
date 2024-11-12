//
//  FriendViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/11/24.
//

import Combine
import FirebaseFirestore

import Combine
import Foundation

class FriendViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var alertMessage: AlertMessage?
    
    private var user: MUser
    private var cancellables = Set<AnyCancellable>()
    
    init(user: MUser) {
        self.user = user
    }
    
    // Метод отправки сообщения с использованием Combine
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        FirestoreService.shared.createWaitingChatPublisher(message: messageText, receiver: user)
            .receive(on: DispatchQueue.main) // Обновляем состояние на главном потоке
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.alertMessage = AlertMessage(message: "Ошибка: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] in
                self?.alertMessage = AlertMessage(message: "Ваше сообщение для \(self?.user.username ?? "") было отправлено.")
                self?.messageText = "" // Очистим поле после отправки
            })
            .store(in: &cancellables)
    }
    
    // Создаем структуру для хранения сообщения алерта
    struct AlertMessage: Identifiable {
        let id = UUID()
        let message: String
    }
}

extension FirestoreService {
    func createWaitingChatPublisher(message: String, receiver: MUser) -> AnyPublisher<Void, Error> {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")
        
        let message = MMessage(user: currentUser, content: message)
        let chat = MChat(friendUsername: currentUser.username,
                         friendAvatarStringURL: currentUser.avatarStringURL,
                         friendId: currentUser.id, lastMessageContent: message.content)
        
        return Future<Void, Error> { promise in
            reference.document(self.currentUser.id).setData(chat.representation) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                messageRef.addDocument(data: message.representation) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


