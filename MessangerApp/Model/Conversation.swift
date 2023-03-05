//
//  Conversation.swift
//  MessangerApp
//
//  Created by choi jun hyung on 3/18/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
    let type: String
    
}
