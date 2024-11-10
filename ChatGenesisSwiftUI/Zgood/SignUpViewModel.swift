//
//  SignUpViewModel.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

class SignUpViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var showImagePicker = false
    @Published var selectedSex = 0
    
    @Published var photo: UIImage?
    
    @Published var errorMessage: String?
    @Published var registrationSuccess = false // Validator for navigating to registration Success view
    @Published var registrationFalse = false // Validator for navigating to registration False view
    
    
//    func registerUser() {
//        guard let positionID = selectedPositionID, let photoImage = photo else {
//            return
//        }
//        
//        // Convert UIImage to Data
//        guard let photoData = photoImage.jpegData(compressionQuality: 0.9) else {
//            return
//        }
//        
//        let userData = UserRegistrationData(
//            name: name,
//            email: email,
//            phone: phone,
//            position_id: positionID,
//            photo: photoData
//        )
//        
//        NetworkManager.shared.registerUser(user: userData) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(_):
//                    self?.objectWillChange.send()  // Notify of the change
//                    self?.registrationSuccess = true
//                    self?.errorMessage = nil
//                case .failure(let error):
//                    self?.objectWillChange.send()  // Notify of the change
//                    self?.registrationFalse = true
//                    self?.errorMessage = error.localizedDescription
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
    
    // Validation for form data fields before submission
    var isFormValid: Bool {
        return validateName && validateEmail && validatePhone && validPhoto()
    }
    
    // Validation for photo
    func validPhoto() -> Bool {
        photo != nil ? true : false
    }
    
    // Validation for registration button
    var isButtonValid: Bool {
        return !name.isEmpty && !email.isEmpty && !phone.isEmpty
    }
    
    // Validation for name
    var validateName: Bool {
        name.count < 2 || name.count > 60 ? false : true
    }
    
    // Validation for email
    var validateEmail: Bool {
        let emailRegEx = #"^(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+)@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"#
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    // Validation for phone
    var validatePhone: Bool {
        let phoneRegEx = #"^\+380\d{9}$"#
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePredicate.evaluate(with: phone)
    }
}
