//
//  ChatsListView.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI
import FirebaseAuth

struct PeopleListView: View {
    @StateObject private var listVM = PeopleListViewModel()
    @FocusState private var isFocused: Bool
    @State var exit = false

    var verticalColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    SearchControllerBar(searchText: $listVM.searchText)  // Привязываем к searchText в ViewModel
                        .focused($isFocused)
                    
                    Button(action: {
                        do {
                            try Auth.auth().signOut()
                            exit = true // This should be whatever variable or logic you're using to track login state.
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                    }) {
                        Image(systemName: "figure.walk.arrival") // You
                            .foregroundColor(.purpleLite)
                            .frame(width: 39, height: 39)
                            .offset(x: -15, y: 5)
                    }

                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(listVM.filteredUsers.count) people nearby")
                            .font(.system(size: 33))
                            .padding(.leading)
                        
                        LazyVGrid(columns: verticalColumns, spacing: 20) {
                            ForEach(listVM.filteredUsers, id: \.id) { user in  // Используем filteredUsers
                                let uiImage = listVM.userImages[user.id] ?? UIImage(named: "avatar")!
                                let image = Image(uiImage: uiImage)
                                
                                NavigationLink(destination: FriendView(user: user, image: uiImage)) {
                                    VStack(alignment: .leading) {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: CGFloat.widthScreen, height: CGFloat.widthScreen)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                        
                                        Text(user.username)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    .shadow(radius: 22)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .navigationDestination(isPresented: $exit) { MainView() }

                    }
                    .hideKeyboard()
                }
            }
        }
    }
}

#Preview {
    PeopleListView()
}
