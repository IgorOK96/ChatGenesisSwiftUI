//
//  ChatAcceptButton.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct ChatAcceptButton: View {
    
    let colorOne: Color
    let colorTwo: Color
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: { action() }
            
        ) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: CGFloat.widthScreen)
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
