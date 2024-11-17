//
//  RequestViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/16/24.
//

import Foundation

class RequestViewModel : ObservableObject {
    @Published var alertMessage: AlertMessage?

    
    func removeWaitingChat(chat: MChat) {
        FirestoreService.shared.deleteWaitingChat(chat: chat) { (result) in
            switch result {
            case .success:
                self.alertMessage = AlertMessage(message: "Успешно!: Чат с \(chat.friendUsername) был удален")
            case .failure(let error):
                self.alertMessage = AlertMessage(message: "Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    func changeToActive(chat: MChat) {
        print(#function)
        FirestoreService.shared.changeToActive(chat: chat) { (result) in
            switch result {
            case .success:
                self.alertMessage = AlertMessage(message: "Успешно!: Приятного общения с \(chat.friendUsername) был удален")
            case .failure(let error):
                self.alertMessage = AlertMessage(message: "Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    // Создаем структуру для хранения сообщения алерта
    struct AlertMessage: Identifiable {
        let id = UUID()
        let message: String
    }
}
