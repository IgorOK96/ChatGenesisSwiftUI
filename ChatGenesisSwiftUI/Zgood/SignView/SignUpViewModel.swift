//
//  SignUpViewModel.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var username = ""
    @Published var description = ""
    @Published var selectedSex = 0
    @Published var avatarImage: UIImage?

    @Published var errorMessage: String?

    @Published var isProfileSaved = false
    @Published var registrationSuccess = false  // Validator for navigating to registration Success view
    let db = Firestore.firestore()

    private var cancellables = Set<AnyCancellable>()
    private let profileLoader = ProfileLoader()
    
    init() {
        loadUserProfile()
    }
        
//MARK: Load User Data
    // Метод для загрузки профиля пользователя
    private func loadUserProfile() {
        guard let uid = AuthService.shared.currentUserUID else {
            self.errorMessage = "Не удалось получить UID текущего пользователя."
            print("Ошибка: UID не получен.")
            return
        }
        
        profileLoader.userProfilePublisher(uid: uid)
            .receive(on: DispatchQueue.main) // Обновляем данные на главном потоке
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("Ошибка загрузки профиля пользователя: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] user in
                self?.username = user.username
                self?.description = user.description
                self?.selectedSex = (user.sex == "Male") ? 0 : 1
                print("Профиль пользователя успешно загружен: \(user.username)")
                
                // Запускаем поток для загрузки аватара
                self?.loadAvatarImage(from: user.avatarStringURL)
            })
            .store(in: &cancellables)
    }
    
    // Метод для загрузки аватара пользователя
    private func loadAvatarImage(from urlString: String) {
        profileLoader.avatarImagePublisher(from: urlString)
            .receive(on: DispatchQueue.main) // Обновляем данные на главном потоке
            .sink { [weak self] image in
                self?.avatarImage = image
                if image != nil {
                    print("Аватар пользователя успешно загружен")
                } else {
                    print("Не удалось загрузить аватар")
                }
            }
            .store(in: &cancellables)
    }
    
//MARK: Save User Data
    func saveUserProfile() {
            guard let uid = AuthService.shared.currentUserUID,
                  let email = AuthService.shared.currentUserEmail else {
                self.errorMessage = "Не удалось получить данные текущего пользователя."
                print("Ошибка: UID или email не получены.")
                return
            }
            
            let sex = selectedSex == 0 ? "Male" : "Female"
            print("Начинаем сохранение профиля с UID: \(uid), email: \(email), имя: \(username)")
            
            FirestoreService.shared.saveUserProfile(
                uid: uid,
                email: email,
                username: username,
                avatarImage: avatarImage, // Передаем UIImage в FirestoreService
                description: description,
                sex: sex
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.isProfileSaved = true
                        print("Профиль успешно сохранен в Firestore.")
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("Ошибка сохранения профиля в Firestore: \(error.localizedDescription)")
                    }
                }
            }
        }
    
//MARK: Registe New User
    func registerEmail() {
        AuthService.shared.register(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.registrationSuccess = true
                    print("Регистрация прошла успешно для пользователя: \(user.email ?? "без email")")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Ошибка при регистрации: \(error.localizedDescription)")
                }
            }
        }
    }
    
//MARK: Valid Method
    
    // Validation for email
    var validateEmail: Bool {
        let emailRegEx = #"^(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+)@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"#
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        !password.isEmpty && password == confirmPassword
    }
    // Validation for form data fields before submission
    var isFormValid: Bool {
        return !password.isEmpty && !confirmPassword.isEmpty && validateEmail && isPasswordValid
    }
    
    var profileValid: Bool {
        return validName && validBio
    }
    // Validation for name
    var validName: Bool {
        username.count < 2 || username.count > 60 ? false : true
    }
    
    // Validation for bio
    var validBio: Bool {
        description.count < 2 || description.count > 60 ? false : true
    }
    
    
    
}
