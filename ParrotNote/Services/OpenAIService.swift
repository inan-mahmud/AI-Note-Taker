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

class OpenAIService {
    static let shared = OpenAIService()
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    /// Sends a chat request to OpenAI API
    /// - Parameter request: The ChatRequest object containing messages and parameters
    /// - Returns: ChatResponse from OpenAI
    /// - Throws: OpenAIServiceError if request fails
    func sendChatRequest(_ request: ChatRequest) async throws -> ChatResponse {
        
        guard let url = URL(string: baseURL) else {
            throw OpenAIServiceError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(Config.openAIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw OpenAIServiceError.decodingError(error)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIServiceError.invalidResponse
            }
            
            // Check for HTTP errors
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to get error message from response
                let errorMessage = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
                throw OpenAIServiceError.apiError(errorMessage)
            }
            
            // Decode successful response
            do {
                let decoder = JSONDecoder()
                let chatResponse = try decoder.decode(ChatResponse.self, from: data)
                return chatResponse
            } catch {
                throw OpenAIServiceError.decodingError(error)
            }
            
        } catch let error as OpenAIServiceError {
            throw error
        } catch {
            throw OpenAIServiceError.networkError(error)
        }
    }
    
    /// Convenience method to send a simple text prompt
    /// - Parameters:
    ///   - prompt: The user's prompt/question
    ///   - systemMessage: Optional system message to set context
    ///   - model: The model to use (default: gpt-4o-mini)
    /// - Returns: The assistant's response text
    /// - Throws: OpenAIServiceError if request fails
    func sendPrompt(_ prompt: String, systemMessage: String? = nil, model: String = "gpt-4o-mini") async throws -> String {
        var messages: [[String: String]] = []
        
        if let systemMessage = systemMessage {
            messages.append(["role": "system", "content": systemMessage])
        }
        
        messages.append(["role": "user", "content": prompt])
        
        let request = ChatRequest(model: model, messages: messages)
        let response = try await sendChatRequest(request)
        
        guard let firstChoice = response.choices.first else {
            throw OpenAIServiceError.invalidResponse
        }
        
        return firstChoice.message.content
    }
}
