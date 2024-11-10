//
//  ChatAcceptButton.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct ChatAcceptButton: View {
    
    var cellWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 20 // Промежуток между ячейками
        return (screenWidth - spacing * 3) / 2 // Учитываем отступы по бокам и между колонками
    }
    
    let colorOne: Color
    let colorTwo: Color
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: {
            // Действие для кнопки Accept
        }) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: cellWidth)
                .padding()
                .background( LinearGradient(
                    gradient: Gradient(colors: [colorOne, colorTwo]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

//#Preview {
//    ChatAcceptButton()
//}
