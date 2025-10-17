//
//  ContentView.swift
//  ParrotNote
//
//  Created by cefalo on 13/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("ParrotNote")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Microphone with pulsing animation
                ZStack {
                    // Outer pulsing rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            .frame(width: 180, height: 180)
                            .scaleEffect(viewModel.pulseAnimation ? 1.5 : 1.0)
                            .opacity(viewModel.pulseAnimation ? 0 : 0.7)
                            .animation(
                                Animation.easeOut(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.4),
                                value: viewModel.pulseAnimation
                            )
                    }
                    
                    // Main microphone button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.toggleRecording()
                        }
                    }) {
                        ZStack {
                            // Button background
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue,
                                            Color.purple
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.blue.opacity(0.5), radius: 20, x: 0, y: 10)
                            
                            // Microphone icon
                            Image(systemName: "mic.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                                .scaleEffect(viewModel.isListening ? 1.1 : 1.0)
                        }
                    }
                    .scaleEffect(viewModel.isListening ? 0.95 : 1.0)
                }
                .frame(height: 250)
                
                // Instruction text
                VStack(spacing: 12) {
                    Text(viewModel.statusText)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(viewModel.instructionText)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .fullScreenCover(isPresented: $viewModel.showLoadingView) {
            LoadingView()
        }
        .sheet(isPresented: $viewModel.showTranscriptView) {
            TranscriptSummaryView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}

