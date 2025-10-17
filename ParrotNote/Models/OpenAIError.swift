//
//  ChatModels.swift
//  ParrotNote
//
//  Created by cefalo on 10/10/25.
//

import Foundation

struct OpenAIError: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
        let type: String
        let param: String?
        let code: String?
    }
}
