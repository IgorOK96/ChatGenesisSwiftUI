//
//  ConversationsView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct ConversationsView: View {
    @State private var searchText = ""
    @FocusState private var isFocused: Bool
    @State var isNew = false
    let imageNames = ["human1", "human2", "human3", "human4", "human5", "human6", "human7", "human8", "human9", "human10"]
    
    // Определяем сетку для горизонтальной прокрутки
    let horizontalColumns = [
        GridItem(.flexible())
    ]
    
    var filteredItems: [String] {
        if searchText.isEmpty {
            return imageNames
        } else {
            return imageNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            SearchControllerBar(searchText: $searchText)
                .focused($isFocused)
            VStack(alignment: .leading, spacing: 20) {
                
                Text("16 chats confirmation waiting")
                    .font(.sansReg(25))
                    .padding(.horizontal, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filteredItems, id: \.self) { imageNames in
                            if let image = UIImage(named: imageNames) {
                                NavigationLink(destination: RequestView(imageAv: image, name: imageNames)) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 90, height: 90)
                                        .shadow(radius: 5)
                                        .cornerRadius(5)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Rectangle()
                    .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    .frame(maxWidth: .infinity) // Расширение по ширине экрана
                    .frame(height: 30)
                
                VStack(alignment: .leading) {
                    Text("Messages")
                        .font(.sansReg(33))
                        .padding(.horizontal, 20)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(filteredItems, id: \.self) { imageName in
                                if let image = UIImage(named: imageName) {
                                    HStack {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .shadow(radius: 5)
                                            .cornerRadius(5)
                                        
                                        VStack(alignment: .leading, spacing: 15) {
                                            Text("My name is Igor")
                                                .font(.sansReg(18))
                                            
                                            Text("Hello, how are you?)))")
                                                .font(.sansReg(18))
                                            
                                        }
                                        Spacer()
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.orange, .purple]),
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                            )
                                            .frame(maxWidth: 15)
                                            .cornerRadius(20)// Расширение по ширине экрана
                                            .frame(height: 80)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .hideKeyboard()
        }
    }
}

#Preview {
    ConversationsView()
}
