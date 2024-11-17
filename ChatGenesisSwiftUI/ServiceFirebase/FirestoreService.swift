//
//  FirestoreService.swift
//  IChat
//
//  Created by Алексей Пархоменко on 01.02.2020.
//  Copyright © 2020 Алексей Пархоменко. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class FirestoreService {
    
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    
    //User ID
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    //Collection User
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    //Collection User >> WaitingChats
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))
    }
    
    //Collection User >> ActiveChats
    private var activeChatsRef: CollectionReference {
        return db.collection(["users", currentUserId, "activeChats"].joined(separator: "/"))
    }
    
    var currentUser: MUser!
        
    //Save Data User > Esc
    func saveUserProfile(uid: String, email: String, username: String, avatarImage: UIImage?, description: String, sex: String, completion: @escaping (Result<MUser, Error>) -> Void) {
            // Проверяем, есть ли аватар для загрузки
            if let avatarImage = avatarImage {
                print("Начинаем загрузку изображения в Storage...")
                // Загружаем фото в Storage
                StorageService.shared.upload(photo: avatarImage) { [weak self] result in
                    switch result {
                    case .success(let url):
                        print("Фото успешно загружено в Storage с URL: \(url)")
                        // Создаем объект MUser с полученным URL
                        let muser = MUser(username: username, email: email, avatarStringURL: url.absoluteString, description: description, sex: sex, id: uid)
                        print("Сохраняем профиль в Firestore с URL аватара...")
                        // Сохраняем данные пользователя в Firestore
                        self?.usersRef.document(muser.id).setData(muser.representation) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                print("Профиль успешно сохранен с URL аватара.")
                                completion(.success(muser))
                            }
                        }
                        
                    case .failure(let error):
                        print("Ошибка загрузки фото в Storage: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            } else {
                print("Изображение не передано, сохраняем профиль без URL аватара.")
                // Если изображения нет, сохраняем профиль без URL аватара
                let muser = MUser(username: username, email: email, avatarStringURL: "", description: description, sex: sex, id: uid)
                usersRef.document(muser.id).setData(muser.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        print("Профиль успешно сохранен без URL аватара.")
                        completion(.success(muser))
                    }
                }
            }
        }

    // Поток для Current User > Combain
    func userProfileListener(uid: String) -> AnyPublisher<MUser, Error> {
        let subject = PassthroughSubject<MUser, Error>()
        
        usersRef.document(uid).addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else if let snapshot = snapshot, snapshot.exists,
                      let muser = MUser(document: snapshot) {
                // Обновляем currentUser
                self?.currentUser = muser
                subject.send(muser)
            } else {
                subject.send(completion: .failure(UserError.cannotUnwrapToMUser))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    // Поток для всех пользователей > Combain
    func allUsersListener() -> AnyPublisher<[MUser], Error> {
        let subject = PassthroughSubject<[MUser], Error>()
        
        usersRef.addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error)) // Обрабатываем ошибку
            } else if let snapshot = snapshot {
                let users = snapshot.documents.compactMap { document in
                    return MUser(document: document) // Преобразуем каждый документ в MUser
                }
                subject.send(users) // Отправляем массив пользователей
            } else {
                subject.send(completion: .failure(UserError.cannotGetUserInfo))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    // Поток для Weit Chats > Combain
    func waitingChatsPublisher() -> AnyPublisher<[MChat], Never> {
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
    
    // Поток для Active Chats > Combain
    func activeChatsPublisher() -> AnyPublisher<[MChat], Never> {
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
    
    // Запрос для чата > Esc
    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")
        
        let message = MMessage(user: currentUser, content: message)
        let chat = MChat(friendUsername: currentUser.username,
                         friendAvatarStringURL: currentUser.avatarStringURL,
                         friendId: currentUser.id, lastMessageContent: message.content)
        
        reference.document(currentUser.id).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            messageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void()))
            }
        }
    }
    
    //Delete Chat + void delete massega 1.1 OR Acc 2.3 > Esc
    func deleteWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    // Delete 1.2 OR Accept 2.4 > Esc
    func deleteMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
                
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageRef = reference.document(documentId)
                    messageRef.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    //Accept Chat >>> Void 2.1 > Esc
    func changeToActive(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { (result) in
                    switch result {
                    case .success:
                        self.createActiveChat(chat: chat, messages: messages) { (result) in
                            switch result {
                            case .success:
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Delete 1.3  OR Accept 2.2 > Esc
    func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        var messages = [MMessage]()
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    // Accept 2.5 > Esc
    func createActiveChat(chat: MChat, messages: [MMessage], completion: @escaping (Result<Void, Error>) -> Void) {
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")
        activeChatsRef.document(chat.friendId).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for message in messages {
                messageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
    
    //Send SMS > Esc
    func sendMessage(chat: MChat, message: MMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageRef = friendRef.collection("messages")
        let myMessageRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")
        
        let chatForFriend = MChat(friendUsername: currentUser.username,
                                  friendAvatarStringURL: currentUser.avatarStringURL,
                                  friendId: currentUser.id,
                                  lastMessageContent: message.content)
        friendRef.setData(chatForFriend.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            friendMessageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                myMessageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
        
    
    func messagesPublisher(chat: MChat) -> AnyPublisher<MMessage, Error> {
        let subject = PassthroughSubject<MMessage, Error>()
        
        let ref = usersRef.document(currentUserId).collection("activeChats").document(chat.friendId).collection("messages")
        let listener = ref.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            querySnapshot?.documentChanges.forEach { (diff) in
                guard let message = MMessage(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    subject.send(message) // Отправляем добавленное сообщение
                case .modified:
                    // Можешь обработать модификации, если нужно
                    break
                case .removed:
                    // Можешь обработать удаление, если нужно
                    break
                }
            }
        }
        
        // Убираем слушатель при отмене подписки
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }

}






/*
func fetchUserProfile(uid: String, completion: @escaping (Result<MUser, Error>) -> Void) {
    let docRef = usersRef.document(uid)
    docRef.getDocument { (document, error) in
        if let document = document, document.exists {
            guard let muser = MUser(document: document) else {
                completion(.failure(UserError.cannotUnwrapToMUser))
                return
            }
            self.currentUser = muser
            completion(.success(muser))
        } else {
            completion(.failure(UserError.cannotGetUserInfo))
        }
    }
}
*/
