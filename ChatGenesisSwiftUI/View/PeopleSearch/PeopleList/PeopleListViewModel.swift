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

    private let imageService = ImageService()
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private let usersCacheKey = "cachedUsers"
    private let imageCacheKeyPrefix = "userImage_"
    
    init() {
        setupSearchPublisher()
        listenToAllUsers()
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
    
    // Метод для подписки на всех пользователей
    private func listenToAllUsers() {
        FirestoreService.shared.allUsersListener()
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
    
    // Загрузка изображений для пользователей
    private func loadImagesForUsers() {
        for user in users {
            guard userImages[user.id] == nil else {
                continue // Пропускаем, если изображение уже загружено
            }
            
            imageService.loadImage(from: user.avatarStringURL) { [weak self] image in
                DispatchQueue.main.async {
                    if let image = image {
                        self?.userImages[user.id] = image
                        print("Изображение для пользователя \(user.id) успешно загружено")
                    } else {
                        print("Не удалось загрузить изображение для пользователя \(user.id)")
                    }
                }
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
}

