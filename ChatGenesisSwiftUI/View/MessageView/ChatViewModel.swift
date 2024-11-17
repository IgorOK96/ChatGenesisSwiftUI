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
    private var cancellables = Set<AnyCancellable>()

    init(user: MUser, chat: MChat) {
        self.user = user
        self.chat = chat
        
        subscribeToMessages()
        setupMessageFilter()

    }
    
    @Published var images: [String: UIImage] = [:]
    private let imageService = ImageService()
    
    func loadImage(for urlString: String) {
        // Проверяем, есть ли изображение уже загружено
        guard images[urlString] == nil else { return }
        
        // Используем ImageService для загрузки
        imageService.loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                if let image = image {
                    self?.images[urlString] = image
                    print("Изображение успешно загружено и закэшировано")
                } else {
                    print("Не удалось загрузить изображение")
                }
            }
        }
    }

    func subscribeToMessages() {
        FirestoreService.shared.messagesPublisher(chat: chat)
            .receive(on: DispatchQueue.main) // Обновляем UI на главном потоке
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Наблюдение за сообщениями завершено.")
                case .failure(let error):
                    print("Ошибка наблюдения за сообщениями: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] message in
                self?.messages.append(message) // Добавляем новое сообщение
            })
            .store(in: &cancellables)
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


