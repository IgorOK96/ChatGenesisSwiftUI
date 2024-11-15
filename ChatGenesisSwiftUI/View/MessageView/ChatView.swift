//
//  ChatView.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/12/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

struct ChatView: View {
    @ObservedObject private var chatVM: ChatViewModel
    @State private var keyboardHeight: CGFloat = 0
    private var keyboardCancellable: AnyCancellable?
    @State private var showConfirmationDialog = false
    @State private var showImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool


    init(user: MUser, chat: MChat) {
        self.chatVM = ChatViewModel(user: user, chat: chat)
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(chatVM.combinedMessagesWithSender, id: \.message.id) { (message, isCurrentUser) in
                            MessageRow(message: message, isCurrentUser: isCurrentUser)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatVM.combinedMessagesWithSender.count) { _, _ in
                    if let lastMessage = chatVM.combinedMessagesWithSender.last?.message {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(chatVM.sendImage == nil ? .blue : .orange)
                }
                
                TextEditor(text: $chatVM.text)
                    .frame(minHeight: 30, maxHeight: 60)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .focused($isFocused)
                
                Button(action: {
                    let trimmedText = chatVM.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let image = chatVM.sendImage {
                        chatVM.sendImageMessage(image: image)
                        chatVM.sendImage = nil
                    } else if !trimmedText.isEmpty {
                        let message = MMessage(user: chatVM.user, content: trimmedText)
                        chatVM.sendMessage(message: message)
                        chatVM.text = "" // очищаем текст после отправки
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 24))
                }
                .disabled(chatVM.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && chatVM.sendImage == nil)
                .confirmationDialog("Choose how you want to add a photo  \n Size no more 5 Mb",
                                    isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                    Button("Camera") {
                        imagePickerSourceType = .camera
                        showImagePicker = true
                    }
                    Button("Gallery") {
                        imagePickerSourceType = .photoLibrary
                        showImagePicker = true
                    }
                    Button("Cancel", role: .cancel) { }
                }
                .fullScreenCover(isPresented: $showImagePicker) {
                    ImagePicker(
                        sourceType: imagePickerSourceType,
                        selectedImage: $chatVM.sendImage,
                        errorMessage: $errorMessage
                    )
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .padding(.bottom, keyboardHeight)
        .hideKeyboard()
        .animation(.easeOut(duration: 0.16), value: keyboardHeight)
        .edgesIgnoringSafeArea(keyboardHeight > 0 ? .bottom : [])
        .navigationBarTitle(chatVM.chat.friendUsername, displayMode: .inline)
        .onAppear {
            chatVM.subscribeToMessages()
        }
        }
    }

struct MessageRow: View {
    var message: MMessage
    var isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            if message.isImage, let imageUrl = URL(string: message.content) {
                // Отображаем изображение, если это сообщение с изображением
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Показать индикатор загрузки
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .cornerRadius(12)
                    case .failure:
                        Text("Не удалось загрузить изображение")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 200, height: 200)
            } else {
                // Отображаем текст, если это обычное текстовое сообщение
                Text(message.content)
                    .padding()
                    .background(isCurrentUser ? Color.purpleLite.opacity(0.7) : Color.orange.opacity(0.7))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(12)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding()
    }
}
