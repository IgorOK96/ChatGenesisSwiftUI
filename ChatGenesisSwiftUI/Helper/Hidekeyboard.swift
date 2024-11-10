//
//  Hidekeyboard.swift
//  TestTaskSfUI
//
//  Created by user246073 on 11/7/24.
//

import SwiftUI

struct HideKeyboardModifier: ViewModifier {
 func body(content: Content) -> some View {
  content
   .onTapGesture {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
   }
   .simultaneousGesture(
    DragGesture().onChanged { _ in
     UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
   )
 }
}

extension View {
 func hideKeyboard() -> some View {
  self.modifier(HideKeyboardModifier())
 }
}
extension Font {
    static func sansReg(_ size: CGFloat) -> Font {
        return Font.custom("NunitoSans-Regular", size: size)
    }
}

extension CGFloat {
    static var widthScreen: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 20 // Промежуток между ячейками
        return (screenWidth - spacing * 3) / 2 // Учитываем отступы по бокам и между колонками
    }
}
