//
//  TabBarView.swift
//  TestTaskSwiftUI
//
//  Created by user246073 on 11/7/24.
//

import SwiftUI

struct TabBarView: View {
    @StateObject private var signVM = SignUpViewModel()

    // Создаем ViewModel здесь
    
    @State private var selectedTab = 0
    @State private var isKeyboardVisible = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    PeopleListView()
                        .tag(0)
                    
                    ChatListView(viewModel: signVM)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide page indicator
                
                if !isKeyboardVisible {
                    // Custom horizontal tab bar
                    HStack(spacing: 0) {
                        TabButton(
                            iconName: selectedTab != 0 ? "person.2" : "person.2.fill",
                            title: "People",
                            isSelected: selectedTab == 0
                        ) {
                            selectedTab = 0
                        }
                        .frame(maxWidth: .infinity)
                        
                        TabButton(
                            iconName:selectedTab != 1 ? "message.badge" : "message.badge.fill",
                            title: "Sign up",
                            isSelected: selectedTab == 1
                        ) {
                            selectedTab = 1
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 40)
                    .offset(y: 10)
                    .background(Color(.systemGray6))
                    .zIndex(1) // Set high z-index for the tab bar
                }
            }
            .navigationBarBackButtonHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardVisible = false
            }
        }
    }
    
}

