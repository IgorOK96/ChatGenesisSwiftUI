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
                TextField("Введите сообщение", text: $chatVM.text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                
                Button(action: {
                    chatVM.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 24))
                }
                .disabled(chatVM.text.isEmpty)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .padding(.bottom, keyboardHeight)
        .animation(.easeOut(duration: 0.16), value: keyboardHeight)
        .edgesIgnoringSafeArea(keyboardHeight > 0 ? .bottom : [])
        .navigationBarTitle(chatVM.chat.friendUsername, displayMode: .inline)
        .onAppear {
            chatVM.subscribeToMessages()
        }
        .onDisappear {
            chatVM.unsubscribe()
            stopObservingKeyboard()
        }
    }
    
    private func stopObservingKeyboard() {
        keyboardCancellable?.cancel()
    }
}

struct MessageRow: View {
    var message: MMessage
    var isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.purpleLite.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.orange.opacity(0.7))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
