//
//  SignUpViewModel.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class SignUpViewModel: ObservableObject {
    @StateObject private var viewModelLogin = LoginViewModel()

    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var username = ""
    @Published var description = ""
    @Published var selectedSex = 0
    @Published var avatarImage: UIImage?
    @Published var avatarImageURL = ""

    @Published var currentUser: MUser?
    @Published var isProfileSaved = false
    
    @Published var errorMessage: String?
    @Published var registrationSuccess = false // Validator for navigating to registration Success view
    @Published var registrationFailure = false
    let db = Firestore.firestore()

//MARK: Read User Data
    func loadUserProfile() {
        guard let uid = AuthService.shared.currentUserUID else {
            self.errorMessage = "Не удалось получить UID текущего пользователя."
            print("Ошибка: UID не получен.")
            return
        }

        FirestoreService.shared.fetchUserProfile(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.username = user.username
                    self?.description = user.description
                    self?.selectedSex = (user.sex == "Male") ? 0 : 1
                    self?.avatarImageURL = user.avatarStringURL
                    print("Профиль пользователя успешно загружен: \(user.username)")
                    
                    // Загрузка аватара, если есть URL
                    self?.loadAvatarImage(from: user.avatarStringURL)
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Ошибка загрузки профиля пользователя: \(error.localizedDescription)")
                }
            }
        }
    }
        
    private func loadAvatarImage(from urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            print("URL аватара пустой или некорректный")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Ошибка загрузки аватара: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Не удалось преобразовать данные в изображение")
                return
            }
            
            DispatchQueue.main.async {
                self?.avatarImage = image
                print("Аватар пользователя успешно загружен")
            }
        }.resume()
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
                    self?.registrationFailure = true
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
        password == confirmPassword
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
