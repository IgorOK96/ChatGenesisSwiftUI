//
//  ChatViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/12/24.
//

import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseStorage

class ChatViewModel: ObservableObject {
    @Published var messages: [MMessage] = []
    @Published var text: String = ""
    @Published var sendImage: UIImage?


    // Объединенный массив с меткой отправителя
    @Published var combinedMessagesWithSender: [(message: MMessage, isCurrentUser: Bool)] = []

    let user: MUser
    let chat: MChat
    private var messageListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    init(user: MUser, chat: MChat) {
        self.user = user
        self.chat = chat
        
        $messages
            .sink { [weak self] _ in
                self?.setupMessageFilter()
            }
            .store(in: &cancellables)
    }

    func subscribeToMessages() {
        messageListener = FirestoreService.shared.messagesObserve(chat: chat) { [weak self] result in
            switch result {
            case .success(let message):
                DispatchQueue.main.async {
                    self?.messages.append(message)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func unsubscribe() {
        messageListener?.remove()
    }

    func sendImageMessage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("chat_images").child("\(imageName).jpg")

        ref.putData(imageData, metadata: nil) {
            [weak self] metadata,
            error in
            if let error = error {
                print("Ошибка загрузки изображения: \(error)")
                return
            }
            
            ref.downloadURL {
                url,
                error in
                if let error = error {
                    print("Ошибка получения URL: \(error)")
                    return
                }
                
                if let url = url {
                    let message = MMessage(
                        user: self?.user ?? MUser(
                            id: "unknown",
                            username: "unknown"
                        ),
                        content: url.absoluteString,
                        isImage: true
                    )
                    self?.sendMessage(message: message)
                }
            }
        }
    }
    
    func sendMessage(message: MMessage) {
            // Метод для відправки повідомлення в Firestore
            FirestoreService.shared.sendMessage(chat: chat, message: message) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.text = ""
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    
    private func setupMessageFilter() {
        $messages
            .map { [weak self] messages in
                messages
                    .sorted { $0.sentDate < $1.sentDate } // Сортируем сообщения по дате
                    .map { message in
                        (message: message, isCurrentUser: message.sender.senderId == self?.user.id)
                    }
            }
            .assign(to: &$combinedMessagesWithSender)
    }
}


