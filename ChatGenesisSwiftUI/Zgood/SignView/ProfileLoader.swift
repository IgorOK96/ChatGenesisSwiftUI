//
//  ProfileLoader.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/12/24.
//

import Combine
import FirebaseFirestore

class ProfileLoader {
    private var db = Firestore.firestore()
    
    // Publisher для загрузки профиля пользователя
    func userProfilePublisher(uid: String) -> AnyPublisher<MUser, Error> {
        Future { promise in
            FirestoreService.shared.fetchUserProfile(uid: uid) { result in
                switch result {
                case .success(let user):
                    promise(.success(user))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Publisher для загрузки аватара пользователя
    func avatarImagePublisher(from urlString: String) -> AnyPublisher<UIImage?, Never> {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            return Just(nil).eraseToAnyPublisher() // Возвращаем nil, если URL пуст или некорректен
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .catch { _ in Just(nil) } // Возвращаем nil, если произошла ошибка загрузки
            .eraseToAnyPublisher()
    }
}
