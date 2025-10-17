//
//  ChatResponse.swift
//  ParrotNote
//
//  Created by cefalo on 11/10/25.
//

import Foundation

struct ChatResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
