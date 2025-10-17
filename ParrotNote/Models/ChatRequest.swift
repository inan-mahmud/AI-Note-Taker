//
//  ChatRequest.swift
//  ParrotNote
//
//  Created by cefalo on 11/10/25.
//

import Foundation

struct ChatRequest: Encodable {
    let model: String
    let messages: [[String: String]]
}
