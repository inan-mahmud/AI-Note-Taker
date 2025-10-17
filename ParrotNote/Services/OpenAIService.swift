//
//  OpenAIService.swift
//  ParrotNote
//
//  Created by cefalo on 10/10/25.
//

import Foundation

enum OpenAIServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case decodingError(Error)
    case networkError(Error)
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .missingAPIKey:
            return "OpenAI API key is missing. Please add your API key."
        }
    }
}

final class OpenAIService {
    static let shared = OpenAIService()
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private init() {}
    
    // MARK: - Core Request
    private func makeURLRequest(from body: Data) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw OpenAIServiceError.invalidURL
        }
        
        guard !Config.openAIKey.isEmpty else {
            throw OpenAIServiceError.missingAPIKey
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(Config.openAIKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = body
        return urlRequest
    }
    
    // MARK: - Generic Sender (returns Data)
    private func sendRawRequest(_ request: ChatRequest) async throws -> Data {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        let urlRequest = try makeURLRequest(from: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIServiceError.invalidResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
                throw OpenAIServiceError.apiError(errorMessage)
            }
            return data
        } catch {
            throw OpenAIServiceError.networkError(error)
        }
    }
    
    // MARK: - Existing Text Prompt (kept as-is)
    func sendPrompt(_ prompt: String, systemMessage: String? = nil, model: String = "gpt-4o-mini") async throws -> String {
        var messages: [[String: String]] = []
        if let systemMessage = systemMessage {
            messages.append(["role": "system", "content": systemMessage])
        }
        messages.append(["role": "user", "content": prompt])
        
        let request = ChatRequest(model: model, messages: messages)
        let data = try await sendRawRequest(request)
        
        do {
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            guard let firstChoice = chatResponse.choices.first else {
                throw OpenAIServiceError.invalidResponse
            }
            return firstChoice.message.content
        } catch {
            throw OpenAIServiceError.decodingError(error)
        }
    }
    
    // MARK: - New: Structured JSON Output
    func sendStructuredPrompt<T: Decodable>(
        _ prompt: String,
        systemMessage: String? = nil,
        model: String = "gpt-4o-mini",
        responseSchema: ChatRequest.ResponseFormat.JSONSchema
    ) async throws -> T {
        var messages: [[String: String]] = []
        if let systemMessage = systemMessage {
            messages.append(["role": "system", "content": systemMessage])
        }
        messages.append(["role": "user", "content": prompt])
        
        let responseFormat = ChatRequest.ResponseFormat(
            type: "json_schema",
            json_schema: responseSchema
        )
        
        let request = ChatRequest(
            model: model,
            messages: messages,
            responseFormat: responseFormat
        )
        
        let data = try await sendRawRequest(request)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw OpenAIServiceError.decodingError(error)
        }
    }
    
    // MARK: - Fetch Meeting Notes (Summary + Action Points)
    func fetchMeetingNotes(from transcript: String, model: String = "gpt-4o-mini") async throws -> MeetingNotes {
        let systemMessage = "Extract a short summary and clear action points from the transcript."
        
        let prompt = transcript
        
        let responseFormat = ChatRequest.ResponseFormat(
            type: "json_schema",
            json_schema: .meetingNotes
        )
        
        var messages: [[String: String]] = []
        messages.append(["role": "system", "content": systemMessage])
        messages.append(["role": "user", "content": prompt])
        
        let request = ChatRequest(
            model: model,
            messages: messages,
            responseFormat: responseFormat
        )
        
        let data = try await sendRawRequest(request)
        
        do {
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            guard let firstChoice = chatResponse.choices.first else {
                throw OpenAIServiceError.invalidResponse
            }
            
            // Decode the content JSON string to MeetingNotes
            let contentData = firstChoice.message.content.data(using: .utf8)!
            return try JSONDecoder().decode(MeetingNotes.self, from: contentData)
        } catch {
            throw OpenAIServiceError.decodingError(error)
        }
    }
}
