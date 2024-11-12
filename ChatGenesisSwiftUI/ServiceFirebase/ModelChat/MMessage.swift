//
//  MMessage.swift
//  IChat
//
//  Created by Алексей Пархоменко on 03.02.2020.
//  Copyright © 2020 Алексей Пархоменко. All rights reserved.
//

import UIKit
import FirebaseFirestore
import MessageKit

struct MMessage: Hashable, MessageType, Identifiable, Comparable {
    let content: String
    var sender: SenderType
    var sentDate: Date
    let id: String?
    let isImage: Bool

    var messageId: String {
        return id ?? UUID().uuidString
    }

    var kind: MessageKind {
        return isImage ? .photo(Media(url: URL(string: content), image: nil, placeholderImage: UIImage(systemName: "photo")!, size: CGSize(width: 240, height: 240))) : .text(content)
    }

    // Реализация протокола Comparable
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
    init(user: MUser, content: String, isImage: Bool = false) {
        self.content = content
        self.isImage = isImage
        self.sender = Sender(senderId: user.id, displayName: user.username)
        self.sentDate = Date()
        self.id = nil
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentDate = data["created"] as? Timestamp else { return nil }
        guard let senderId = data["senderID"] as? String else { return nil }
        guard let senderName = data["senderName"] as? String else { return nil }
        guard let content = data["content"] as? String else { return nil }
        let isImage = data["isImage"] as? Bool ?? false

        self.id = document.documentID
        self.sentDate = sentDate.dateValue()
        self.sender = Sender(senderId: senderId, displayName: senderName)
        self.content = content
        self.isImage = isImage
    }

    var representation: [String: Any] {
        return [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName,
            "content": content,
            "isImage": isImage
        ]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

// Дополнительная структура для поддержки .photo типа в MessageKind
struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}
