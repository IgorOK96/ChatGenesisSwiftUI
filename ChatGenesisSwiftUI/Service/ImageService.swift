//
//  ImageService.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/16/24.
//
import UIKit
import Alamofire
import AlamofireImage

class ImageService {
    private let imageCache = NSCache<NSString, UIImage>()
    
    // Метод для загрузки изображения
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Проверяем наличие изображения в кэше
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage) // Возвращаем изображение из кэша
            print("Изображение загружено из кэша")
            return
        }
        
        // Проверяем корректность URL
        guard let url = URL(string: urlString) else {
            print("Некорректный URL")
            completion(nil)
            return
        }
        
        // Загружаем изображение через Alamofire
        AF.request(url).responseImage { [weak self] response in
            switch response.result {
            case .success(let image):
                // Кэшируем изображение
                self?.imageCache.setObject(image, forKey: urlString as NSString)
                completion(image) // Возвращаем изображение
                print("Изображение успешно загружено через Alamofire")
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
