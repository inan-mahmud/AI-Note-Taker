//
//  LoadingView.swift
//  ParrotNote
//
//  Created by cefalo on 17/10/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var particleAnimations: [Bool] = Array(repeating: false, count: 8)
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.1, green: 0.15, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particles in background
            ForEach(0..<8) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .blur(radius: 20)
                    .offset(
                        x: particleAnimations[index] ? CGFloat.random(in: -150...150) : 0,
                        y: particleAnimations[index] ? CGFloat.random(in: -300...300) : 0
                    )
                    .opacity(particleAnimations[index] ? 0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...3))
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.2),
                        value: particleAnimations[index]
                    )
            }
            
            VStack(spacing: 40) {
                // Animated AI brain/sparkles icon
                ZStack {
                    // Outer rotating ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.purple,
                                    Color.pink,
                                    Color.blue
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(rotationAngle))
                        .opacity(0.6)
                    
                    // Middle pulsing ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple,
                                    Color.blue
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(scale)
                        .opacity(0.5)
                    
                    // Center icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.8),
                                        Color.purple.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.blue.opacity(0.5), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(-rotationAngle * 0.5))
                    }
                }
                .opacity(opacity)
                
                // Text content
                VStack(spacing: 16) {
                    Text("Generating Summary")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)
                    
                    Text("AI is analyzing your transcript...")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                    
                    // Animated dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 10, height: 10)
                                .scaleEffect(scale)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: scale
                                )
                        }
                    }
                    .padding(.top, 8)
                    .opacity(opacity)
                }
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.easeInOut(duration: 0.5)) {
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
            
            // Start particle animations
            for index in particleAnimations.indices {
                particleAnimations[index] = true
            }
        }
    }
}

#Preview {
    LoadingView()
}
