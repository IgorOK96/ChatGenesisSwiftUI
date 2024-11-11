//
//  RequestView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI




struct RequestView: View {
    let imageAv: UIImage
    let name: String
    
    var cellWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 20 // Промежуток между ячейками
        return (screenWidth - spacing * 3) / 2 // Учитываем отступы по бокам и между колонками
    }
    
    var body: some View {
         ZStack(alignment: .bottom) { // Задаем выравнивание по низу для ZStack
             Image(uiImage: imageAv)
                 .resizable()
                 .aspectRatio(contentMode: .fill)
                 .ignoresSafeArea() // Растягиваем изображение на весь экран
             
             VStack(alignment: .leading ,spacing: 20) {
                 // Текст заголовка
                 Text(name)
                     .font(.system(size: 20, weight: .bold))
                     .foregroundColor(.black)
                 
                 // Подзаголовок
                 Text("You have the opportunity to start a new chat")
                     .font(.system(size: 16))
                     .foregroundColor(.gray)
                 
                 // Кнопки
                 HStack(spacing: 20) {
                     // Кнопка "Accept" с градиентом
                     ChatAcceptButton(
                        colorOne: .orange,
                        colorTwo: .purple
                         ,
                        title: "ACCEPT",
                        action: {}
                     )
                     
                     // Кнопка "Deny" с красной рамкой
                     ChatAcceptButton(
                        colorOne: .red,
                        colorTwo: .black,
                        title: "Deny",
                        action: {}
                     )
                 }
                 .padding(.horizontal, 20)
             }
             .padding()
             .frame(width: cellWidth * 2 + 20)
             .background(Color.white)
             .cornerRadius(20)
             .shadow(radius: 10)
             .padding(.horizontal, 20)
         }
     }
 }

//#Preview {
//    RequestView()
//}
