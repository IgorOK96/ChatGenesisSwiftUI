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

class FirestoreService {
    
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
        
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
        
    var currentUser: MUser!
    
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
    
    func messagesObserve(chat: MChat, completion: @escaping (Result<MMessage, Error>) -> Void) -> ListenerRegistration? {
        let ref = usersRef.document(currentUserId).collection("activeChats").document(chat.friendId).collection("messages")
        let messagesListener = ref.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let message = MMessage(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return messagesListener
    }

}
