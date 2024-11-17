//
//  ChatListViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/11/24.
//

import Combine
import FirebaseFirestore
import FirebaseAuth

class ChatsListViewModel: ObservableObject {
    private let imageService = ImageService()
    @Published var activeChats: [MChat] = []
    @Published var waitingChats: [MChat] = []

    @Published var waitActiveImages: [String: UIImage] = [:]
    
    @Published var filteredWait: [MChat] = []  // Отфильтрованные чаты
    @Published var filteredActive: [MChat] = []  // Отфильтрованные чаты
    @Published var searchText: String = ""      // Текст для поиска

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSearchActive()
        setupSearchWait()
        observeAuthenticationState()
    }
    
    // VALID FOR AUTH USER
    private func observeAuthenticationState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("Пользователь авторизован: \(user.uid)")
                self?.fetchActiveChats()
                self?.fetchWaitingChats()
            } else {
                print("Пользователь не авторизован")
            }
        }
    }
    
    //Waiting Chat fetch > Combain
    private func fetchWaitingChats() {
        FirestoreService.shared.waitingChatsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chats in
                self?.waitingChats = chats
                self?.loadImagesForChats(chats) // Загружаем фото только для новых пользователей
            }
            .store(in: &cancellables)
    }

    //Active Chat fetch > Combain
    private func fetchActiveChats() {
        FirestoreService.shared.activeChatsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chats in
                self?.activeChats = chats
                self?.loadImagesForChats(chats) // Тоже проверяем и загружаем только новые
            }
            .store(in: &cancellables)
    }
    
    // Load Image for Weit \ Active Chats
    func loadImagesForChats(_ chats: [MChat]) {
        for chat in chats {
            guard waitActiveImages[chat.friendId] == nil else {
                // Если фото уже есть в кэше, пропускаем
                continue
            }
            
            // Загружаем фото, если его нет в кэше
            imageService.loadImage(from: chat.friendAvatarStringURL) { [weak self] image in
                DispatchQueue.main.async {
                    if let image = image {
                        self?.waitActiveImages[chat.friendId] = image
                        print("Фото для \(chat.friendId) загружено.")
                    } else {
                        print("Не удалось загрузить фото для \(chat.friendId).")
                    }
                }
            }
        }
    }
    
    // Search Bar
    private func setupSearchActive() {
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
            .assign(to: &$filteredActive)
    }

    // Search Bar
    private func setupSearchWait() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest($waitingChats)
            .map { (searchText, chats) -> [MChat] in
                guard !searchText.isEmpty else {
                    return chats
                }
                return chats.filter { chat in
                    chat.friendUsername.localizedCaseInsensitiveContains(searchText)
                }
            }
            .assign(to: &$filteredWait)
    }
}
