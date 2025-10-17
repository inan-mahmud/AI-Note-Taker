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
    let response_format: ResponseFormat?

    struct ResponseFormat: Encodable {
        let type: String
        let json_schema: JSONSchema?

        struct JSONSchema: Encodable {
            let name: String
            let schema: Schema

            struct Schema: Encodable {
                let type: String
                let properties: [String: Property]
                let required: [String]

                struct Property: Encodable {
                    let type: String
                    let items: PropertyItems?

                    struct PropertyItems: Encodable {
                        let type: String
                    }
                }
            }
        }
    }

    init(model: String, messages: [[String: String]], responseFormat: ResponseFormat? = nil) {
        self.model = model
        self.messages = messages
        self.response_format = responseFormat
    }
}

struct MeetingNotes: Codable {
    let summary: String
    let action_points: [String]
}

extension ChatRequest.ResponseFormat.JSONSchema {
    static var meetingNotes: ChatRequest.ResponseFormat.JSONSchema {
        let actionProperty = ChatRequest.ResponseFormat.JSONSchema.Schema.Property(
            type: "array",
            items: .init(type: "string")
        )
        
        let schema = ChatRequest.ResponseFormat.JSONSchema.Schema(
            type: "object",
            properties: [
                "summary": .init(type: "string", items: nil),
                "action_points": actionProperty
            ],
            required: ["summary", "action_points"]
        )
        
        return ChatRequest.ResponseFormat.JSONSchema(
            name: "meeting_notes",
            schema: schema
        )
    }
}
