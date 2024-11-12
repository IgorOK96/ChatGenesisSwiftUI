//
//  PeopleListViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/11/24.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class PeopleListViewModel: ObservableObject {
    @Published var users: [MUser] = []  // Все пользователи
    @Published var filteredUsers: [MUser] = []  // Отфильтрованные пользователи
    @Published var searchText: String = ""  // Текст для поиска
    @Published var userImages: [String: UIImage] = [:]

    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private let usersCacheKey = "cachedUsers"
    private let imageCacheKeyPrefix = "userImage_"
    
    init() {
        setupSearchPublisher()
        
        fetchAllUsersPublisher()
            .receive(on: DispatchQueue.main) // Обновляем UI на главном потоке
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Ошибка загрузки пользователей: \(error.localizedDescription)")
                    self.loadCachedUsers() // Если ошибка, загружаем кэшированные данные
                }
            }, receiveValue: { [weak self] users in
                self?.users = users
                self?.cacheUsers(users) // Кэшируем данные пользователей
                self?.loadImagesForUsers() // Загружаем изображения для пользователей
            })
            .store(in: &cancellables)
    }
    
    //Search Map filter
    private func setupSearchPublisher() {
            $searchText
                .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .combineLatest($users)
                .map { searchText, users in
                    users.filter { user in
                        searchText.isEmpty || user.username.localizedCaseInsensitiveContains(searchText)
                    }
                }
                .assign(to: &$filteredUsers)
        }
    
    // Поток для всех пользователей
    func fetchAllUsersPublisher() -> AnyPublisher<[MUser], Error> {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return Fail(error: NSError(domain: "auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить текущего пользователя"])).eraseToAnyPublisher()
        }
        
        let usersCollection = db.collection("users")
        
        return usersCollection
            .snapshotPublisher()
            .map { snapshot in
                snapshot.documents.compactMap { document in
                    let user = MUser(document: document)
                    return user?.id == currentUserID ? nil : user // Исключаем текущего пользователя
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Кэширование пользователей
    private func cacheUsers(_ users: [MUser]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(users) {
            UserDefaults.standard.set(data, forKey: usersCacheKey)
        }
    }
    
    // Загрузка кэшированных пользователей
    private func loadCachedUsers() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: usersCacheKey),
           let cachedUsers = try? decoder.decode([MUser].self, from: data) {
            self.users = cachedUsers
            loadImagesForUsers() // Загружаем изображения из кэша или сети
        }
    }
    
    // Загрузка изображений для пользователей
    private func loadImagesForUsers() {
        for user in users {
            guard userImages[user.id] == nil else {
                continue // Пропускаем, если изображение уже загружено
            }
            
            if let cachedImage = loadCachedImage(for: user.id) {
                userImages[user.id] = cachedImage // Загружаем изображение из кэша
            } else if let url = URL(string: user.avatarStringURL) {
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.userImages[user.id] = image
                            self?.cacheImage(image, for: user.id) // Кэшируем изображение
                        }
                    }
                }.resume()
            }
        }
    }
    
    // Кэширование изображения
    private func cacheImage(_ image: UIImage, for userId: String) {
        let key = imageCacheKeyPrefix + userId
        if let data = image.pngData() {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // Загрузка кэшированного изображения
    private func loadCachedImage(for userId: String) -> UIImage? {
        let key = imageCacheKeyPrefix + userId
        if let data = UserDefaults.standard.data(forKey: key) {
            return UIImage(data: data)
        }
        return nil
    }
}

extension CollectionReference {
    func snapshotPublisher() -> AnyPublisher<QuerySnapshot, Error> {
        let subject = PassthroughSubject<QuerySnapshot, Error>()
        
        let listener = self.addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else if let snapshot = snapshot {
                subject.send(snapshot)
            }
        }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove() // Отключаем слушатель при отмене подписки
            })
            .eraseToAnyPublisher()
    }
}
