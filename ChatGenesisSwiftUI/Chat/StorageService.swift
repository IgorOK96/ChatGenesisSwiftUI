//
//  StorageService.swift
//  IChat
//
//  Created by Алексей Пархоменко on 02.02.2020.
//  Copyright © 2020 Алексей Пархоменко. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class StorageService {
    
    static let shared = StorageService()

    let storageRef = Storage.storage().reference()
    
    private var avatarsRef: StorageReference {
        return storageRef.child("avatars")
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = photo.scaledToSafeUploadSize()?.jpegData(compressionQuality: 0.4) else {
            print("Failed to generate image data")
            completion(.failure(NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data is nil"])))
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }
        
        avatarsRef.child(currentUserId).putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            print("Image uploaded successfully")
            // Загрузка URL после успешного сохранения
            self.avatarsRef.child(self.currentUserId).downloadURL { (url, error) in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                guard let downloadURL = url else {
                    print("Download URL is nil")
                    return
                }
                print("Download URL retrieved: \(downloadURL)")
                completion(.success(downloadURL))
            }
        }
    }
}
