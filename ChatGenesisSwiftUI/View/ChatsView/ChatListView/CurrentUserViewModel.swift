//
//  CurrentUserViewModel.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/12/24.
//

import Combine
import FirebaseAuth
import FirebaseFirestore

class CurrentUserViewModel: ObservableObject {
    @Published var currentUser: MUser?

    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchCurrentUser()
    }

    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid)
            .addSnapshotListener { [weak self] (documentSnapshot, error) in
                if let error = error {
                    print("Ошибка получения текущего пользователя: \(error.localizedDescription)")
                } else if let document = documentSnapshot, let user = MUser(document: document) {
                    self?.currentUser = user
                }
            }
    }
}
