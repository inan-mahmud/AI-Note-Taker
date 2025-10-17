//
//  ContentViewModel.swift
//  ParrotNote
//
//  Created by cefalo on 4/10/25.
//

import SwiftUI
import AVFoundation
import Speech
import NaturalLanguage

@MainActor
@Observable
class ContentViewModel {
    var isListening = false
    var pulseAnimation = false
    var statusText = "Tap to Start"
    var instructionText = "Press the microphone to begin recording"
    var currentTranscript = ""
    var transcriptSummary = ""
    var extractedKeywords: [String] = []
    var showTranscriptView = false
    var isGeneratingSummary = false
    
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    func onAppear() {
        requestPermissions()
        pulseAnimation = true
    }
    
    func toggleRecording() {
        if isListening {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognition not available")
            return
        }
        
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session configuration failed: \(error)")
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Create audio engine and input node
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            print("Unable to create audio engine")
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
            return
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let result = result {
                    let transcription = result.bestTranscription.formattedString
                    self.currentTranscript = transcription
                    self.statusText = "Listening..."
                    self.instructionText = transcription.isEmpty ? "Speak now" : transcription
                }
            }
        }
        
        isListening = true
        statusText = "Listening..."
        instructionText = "Speak now"
    }
    
    func stopRecording() {
        // Save the current transcript before cleaning up
        let savedTranscript = currentTranscript
        
        // Wait a moment for final recognition results
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            await MainActor.run {
                audioEngine?.stop()
                audioEngine?.inputNode.removeTap(onBus: 0)
                recognitionRequest?.endAudio()
                
                // Wait another moment before canceling the task
                Task {
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                    
                    await MainActor.run {
                        recognitionTask?.cancel()
                        
                        audioEngine = nil
                        recognitionRequest = nil
                        recognitionTask = nil
                        
                        isListening = false
                        statusText = "Tap to Start"
                        
                        // Use the most recent transcript (in case it updated during the delay)
                        let finalTranscript = currentTranscript.isEmpty ? savedTranscript : currentTranscript
                        
                        if !finalTranscript.isEmpty {
                            currentTranscript = finalTranscript
                            extractedKeywords = extractKeywords(from: currentTranscript)
                            showTranscriptView = true
                            
                            // Generate summary using OpenAI
                            Task {
                                await generateAISummary()
                            }
                        } else {
                            instructionText = "No speech detected. Try again."
                        }
                    }
                }
            }
        }
    }
    
    private func generateAISummary() async {
        isGeneratingSummary = true
        transcriptSummary = "Generating summary..."
        
        do {
            let systemMessage = "You are an expert at creating concise summaries. Create a brief 2-3 sentence summary highlighting the main points."
            
            let prompt = """
            Please summarize the following transcript in 2-3 sentences:
            
            \(currentTranscript)
            """
            
            let summary = try await OpenAIService.shared.sendPrompt(prompt, systemMessage: systemMessage)
            
            await MainActor.run {
                transcriptSummary = summary
                isGeneratingSummary = false
            }
        } catch {
            await MainActor.run {
                transcriptSummary = "Failed to generate summary: \(error.localizedDescription)"
                isGeneratingSummary = false
            }
        }
    }
    
    private func extractKeywords(from text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma])
        tagger.string = text
        
        var keywords: [String: Int] = [:]
        
        // Extract nouns and proper nouns as keywords
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if let tag = tag, (tag == .noun || tag == .personalName || tag == .placeName || tag == .organizationName) {
                let word = String(text[tokenRange]).lowercased()
                // Filter out very short words
                if word.count > 3 {
                    keywords[word, default: 0] += 1
                }
            }
            return true
        }
        
        // Return top 5 keywords sorted by frequency
        return keywords.sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key.capitalized }
    }
    
    private func extractTopSentences(from text: String) -> String {
        guard !text.isEmpty else { return text }
        
        // Tokenize text into sentences
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        var sentences: [(String, Double)] = []
        
        // Calculate importance score for each sentence
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let sentence = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                let score = calculateSentenceScore(sentence, in: text)
                sentences.append((sentence, score))
            }
            return true
        }
        
        // If only 1-2 sentences, return the full text
        if sentences.count <= 2 {
            return text
        }
        
        // Sort by score and take top 3 sentences
        let topSentences = sentences
            .sorted { $0.1 > $1.1 }
            .prefix(3)
        
        // Reorder to maintain original sequence
        let topSentenceTexts = Set(topSentences.map { $0.0 })
        let orderedSummary = sentences
            .filter { topSentenceTexts.contains($0.0) }
            .map { $0.0 }
            .joined(separator: " ")
        
        return orderedSummary
    }
    
    private func calculateSentenceScore(_ sentence: String, in fullText: String) -> Double {
        // Score based on:
        // 1. Position (first and last sentences are important)
        // 2. Length (not too short, not too long)
        // 3. Keyword density
        
        var score = 0.0
        
        // Length score
        let wordCount = sentence.split(separator: " ").count
        if wordCount >= 5 && wordCount <= 20 {
            score += 1.0
        }
        
        // Keyword density score
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = sentence
        
        var keywordCount = 0
        tagger.enumerateTags(in: sentence.startIndex..<sentence.endIndex, unit: .word, scheme: .lexicalClass) { tag, _ in
            if let tag = tag, (tag == .noun || tag == .personalName || tag == .placeName || tag == .organizationName) {
                keywordCount += 1
            }
            return true
        }
        
        score += Double(keywordCount) * 0.5
        
        return score
    }
    
    private func requestPermissions() {
        // Request speech recognition permission
        SFSpeechRecognizer.requestAuthorization { authStatus in
            Task { @MainActor in
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition denied")
                    self.statusText = "Permission Denied"
                    self.instructionText = "Enable speech recognition in Settings"
                case .restricted:
                    print("Speech recognition restricted")
                    self.statusText = "Not Available"
                    self.instructionText = "Speech recognition is restricted on this device"
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    print("Unknown speech recognition status")
                }
            }
        }
        
        // Request microphone permission
        AVAudioApplication.requestRecordPermission { granted in
            Task { @MainActor in
                if granted {
                    print("Microphone permission granted")
                } else {
                    print("Microphone permission denied")
                    self.statusText = "Permission Denied"
                    self.instructionText = "Enable microphone access in Settings"
                }
            }
        }
    }
}
