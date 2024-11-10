//
//  FriendView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/10/24.
//

import SwiftUI

struct FriendView: View {
    let image: UIImage
    let name: String
    @State private var sendMassage = false
    @State var message: String
    @State var valid = true
    
    var body: some View {
        ZStack(alignment: .bottom) { // Задаем выравнивание по низу для ZStack
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea() // Растягиваем изображение на весь экран
            
            VStack(alignment: .leading, spacing: 20) {
                // Текст заголовка
                Text(name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                // Подзаголовок
                Text("You have the opportunity to start a new chat")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                // Поле ввода и кнопка отправки
                HStack(spacing: 10) { // Добавляем промежуток между TextField и кнопкой
                    TextFieldView(
                        text: $message,
                        isValid: $valid,
                        placeholder: "Your First Message!",
                        errorText: "",
                        padding: 10
                    )
                    
                    Button(action: { sendMassage = true }) {
                        Image("Sent")
                            .resizable()
                            .frame(width: 35, height: 35)
                    }
                    .offset(x: -5, y: -9)
                }
                .padding(.vertical, 10) // Добавляем отступы сверху и снизу
                
            }
            .padding()
            .frame(width: CGFloat.widthScreen * 2 + 20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}


#Preview {
    FriendView(
        image: UIImage(systemName: "person.fill") ?? UIImage(imageLiteralResourceName: "human1"), // Используем системное изображение как заглушку
        name: "John Doe",
        message: "Hey! How are you doing?"
    )
}
