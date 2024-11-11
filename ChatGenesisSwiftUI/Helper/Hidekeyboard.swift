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

extension UIImage {
    func scaledToSafeUploadSize(maxSize: CGFloat = 1024) -> UIImage? {
        let largerDimension = max(size.width, size.height)
        let scale = largerDimension > maxSize ? maxSize / largerDimension : 1.0
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: newSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
