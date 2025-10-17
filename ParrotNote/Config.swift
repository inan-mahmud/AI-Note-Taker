//
//  Config.swift
//  ParrotNote
//
//  Created by cefalo on 14/10/25.
//

import Foundation

enum Config {
    static var openAIKey: String {
        guard let key = ProcessInfo.processInfo.environment["OPEN_AI_KEY"] else {
            fatalError("Missing OPENAI_API_KEY in .env file")
        }
        return key
    }
}
