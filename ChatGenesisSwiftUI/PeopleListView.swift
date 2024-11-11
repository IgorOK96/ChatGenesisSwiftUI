//
//  ChatsListView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct PeopleListView: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    @State private var searchText = ""
    @FocusState private var isFocused: Bool

    let imageNames = ["human1", "human2", "human3", "human4", "human5", "human6", "human7", "human8", "human9", "human10"]

    var verticalColumns: [GridItem] {
        [GridItem(.flexible()),
         GridItem(.flexible())]
    }
    
    var filteredItems: [String] {
        if searchText.isEmpty {
            return imageNames
        } else {
            return imageNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Вычисляем ширину ячейки с учетом ширины экрана и отступов
    var cellWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 20 // Промежуток между ячейками
        return (screenWidth - spacing * 3) / 2 // Учитываем отступы по бокам и между колонками
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchControllerBar(searchText: $searchText)
                    .focused($isFocused)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Вертикальная секция
                        Text("\(filteredItems.count) people nearby")
                            .font(.system(size: 33))
                            .padding(.leading)
                        
                        LazyVGrid(columns: verticalColumns, spacing: 20) {
                            ForEach(filteredItems, id: \.self) { imageNames in
                                if let image = UIImage(named: imageNames) {
                                    NavigationLink(destination: FriendView(image: image, name: imageNames, message: "")) {
                                        VStack(alignment: .leading) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: cellWidth, height: cellWidth)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                            
                                            Text(imageNames)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        }
                                        .shadow(radius: 22)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .hideKeyboard()
                }
            }.onAppear { viewModel.loadUserProfile() }
        }
    }
}



#Preview {
    PeopleListView()
}
