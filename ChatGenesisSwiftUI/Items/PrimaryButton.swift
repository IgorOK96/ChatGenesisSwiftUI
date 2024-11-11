//
//  PrimaryButton.swift
//  TestTaskSfUI
//
//  Created by user246073 on 11/7/24.
//
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let mod: Bool  // true dark style, false lite style
    var supportText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
                Text(supportText)
                    .font(.sansReg(20))
                Button(action: { action() }) {
                    Text(title)
                }
                .buttonStyle(PressableButtonStyle(mod: mod))
            }
            .padding(.horizontal, 35)
        }
    }

struct PressableButtonStyle: ButtonStyle {
    let mod: Bool
    let colorPurpleLite = Color(.purpleLite)
    let colorPurpleDark = Color(.purpleDark)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sansReg(20))
            .foregroundColor(mod ? .white : (configuration.isPressed ? .white : colorPurpleLite))
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(mod ? (configuration.isPressed ? colorPurpleDark : colorPurpleLite) : (configuration.isPressed ? colorPurpleLite : .white))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(mod ? (configuration.isPressed ? colorPurpleDark : colorPurpleLite) : colorPurpleLite, lineWidth: 2)
            )
    }
}

//#Preview {
//    PrimaryButton(title: "Sign up", action: {}, mod: false, supportText: "Get started with")
//}
