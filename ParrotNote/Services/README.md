# OpenAI Service Documentation

## Overview
The `OpenAIService` class provides a simple interface to interact with OpenAI's Chat Completions API using async/await.

## Setup

### 1. Get Your API Key
1. Go to [OpenAI API Keys](https://platform.openai.com/api-keys)
2. Create a new API key
3. Copy the key

### 2. Configure the API Key

**Option 1: Using Config File (Quick Start)**
```swift
// In OpenAIConfig.swift
static let apiKey = "sk-your-api-key-here"
```

**Option 2: Using Environment Variable (Recommended for Production)**
```bash
# In Xcode: Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables
OPENAI_API_KEY = sk-your-api-key-here
```

## Usage

### Simple Text Prompt
```swift
let response = try await OpenAIService.shared.sendPrompt("What is Swift?")
print(response)
```

### With System Message
```swift
let systemMessage = "You are a helpful assistant."
let response = try await OpenAIService.shared.sendPrompt(
    "Explain async/await",
    systemMessage: systemMessage
)
```

### Custom Request
```swift
let messages = [
    Message(role: Message.Role.system, content: "You are a summarizer."),
    Message(role: Message.Role.user, content: "Summarize: [text]")
]

let request = ChatRequest(
    model: "gpt-3.5-turbo",
    messages: messages,
    temperature: 0.7,
    maxTokens: 500
)

let response = try await OpenAIService.shared.sendChatRequest(request)
```

### Error Handling
```swift
do {
    let response = try await OpenAIService.shared.sendPrompt("Hello")
    print(response)
} catch OpenAIServiceError.missingAPIKey {
    print("Please configure your API key")
} catch OpenAIServiceError.apiError(let message) {
    print("API Error: \(message)")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

## Models

### ChatRequest
- `model`: String (e.g., "gpt-3.5-turbo", "gpt-4")
- `messages`: Array of Message objects
- `temperature`: Optional Double (0.0 - 2.0)
- `maxTokens`: Optional Int
- `topP`: Optional Double
- `frequencyPenalty`: Optional Double
- `presencePenalty`: Optional Double

### Message
- `role`: String ("system", "user", or "assistant")
- `content`: String (the message content)

### ChatResponse
- `id`: String
- `model`: String
- `choices`: Array of Choice objects
- `usage`: Usage information (tokens used)

## Best Practices

1. **Never commit API keys to version control**
2. **Use environment variables in production**
3. **Handle errors appropriately**
4. **Monitor token usage via `response.usage`**
5. **Set appropriate `maxTokens` to control costs**
6. **Use lower `temperature` for more focused responses**

## Security Notes

⚠️ **Important**: 
- Never hardcode API keys in production apps
- Use Keychain or secure configuration services
- Consider using a backend proxy for API calls in production
- The API key should never be exposed in client-side code

## Available Models

- `gpt-3.5-turbo` - Fast and cost-effective
- `gpt-4` - More capable but slower and more expensive
- `gpt-4-turbo` - Faster GPT-4 variant

See [OpenAI Models](https://platform.openai.com/docs/models) for the full list.
