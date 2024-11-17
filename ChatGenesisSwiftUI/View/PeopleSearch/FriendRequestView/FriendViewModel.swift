//
//  FriendViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/11/24.
//

import Combine
import FirebaseFirestore
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
        
        FirestoreService.shared.createWaitingChat(message: messageText, receiver: user) { [weak self] result in
            DispatchQueue.main.async { // Убедимся, что обновляем UI на главном потоке
                switch result {
                case .success:
                    self?.alertMessage = AlertMessage(message: "Ваше сообщение для \(self?.user.username ?? "") было отправлено.")
                    self?.messageText = "" // Очистим поле после отправки
                case .failure(let error):
                    self?.alertMessage = AlertMessage(message: "Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Создаем структуру для хранения сообщения алерта
    struct AlertMessage: Identifiable {
        let id = UUID()
        let message: String
    }
}


