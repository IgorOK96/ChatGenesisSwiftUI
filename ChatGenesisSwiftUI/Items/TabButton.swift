//
//  TabButton.swift
//  TestTaskSfUI
//
//  Created by user246073 on 11/7/24.

import SwiftUI

struct TabButton: View {
    let customColor = Color(.purpleLite)
    let iconName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(isSelected ? .orange : customColor)
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .orange : customColor)
            }
            .padding()
        }
    }
}

#Preview {
    TabButton(iconName: "car", title: "User", isSelected: false, action: {})
}
