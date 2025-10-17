//
//  TranscriptSummaryView.swift
//  ParrotNote
//
//  Created by cefalo on 10/10/25.
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

struct TranscriptSummaryView: View {
    @Bindable var viewModel: ContentViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient matching the main view
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Keywords Section
                        if !viewModel.extractedKeywords.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.green)
                                    Text("Keywords")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(viewModel.extractedKeywords, id: \.self) { keyword in
                                        Text(keyword)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color.green.opacity(0.6), Color.teal.opacity(0.6)]),
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Summary Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                Text("Summary")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                if viewModel.isGeneratingSummary {
                                    Spacer()
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                            .scaleEffect(0.8)
                                        Text("AI is generating...")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            if viewModel.isGeneratingSummary {
                                // Shimmer loading skeleton
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(0..<3) { index in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.1),
                                                        Color.white.opacity(0.2),
                                                        Color.white.opacity(0.1)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(height: 16)
                                            .frame(maxWidth: index == 2 ? .infinity * 0.6 : .infinity)
                                            .shimmer()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            } else if viewModel.transcriptSummary.isEmpty {
                                Text("No summary available")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                    .italic()
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            } else {
                                Text(viewModel.transcriptSummary)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }
                        }
                        
                        // Transcript Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.purple)
                                Text("Full Transcript")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            Text(viewModel.currentTranscript)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            // Copy Transcript Button
                            Button(action: {
                                copyToClipboard()
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc.fill")
                                    Text("Copy Transcript")
                                }
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            
                            #if os(iOS)
                            // Share Button (iOS only)
                            Button(action: {
                                shareTranscript()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.fill")
                                    Text("Share")
                                }
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            #endif
                        }
                        .padding(.top, 10)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Recording Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                for: .navigationBar
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.showTranscriptView = false
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
        }
    }
    
    private func copyToClipboard() {
        var textToCopy = ""
        
        if !viewModel.extractedKeywords.isEmpty {
            textToCopy += "Keywords: \(viewModel.extractedKeywords.joined(separator: ", "))\n\n---\n\n"
        }
        
        if !viewModel.transcriptSummary.isEmpty && !viewModel.isGeneratingSummary {
            textToCopy += "Summary:\n\n\(viewModel.transcriptSummary)\n\n---\n\n"
        }
        
        textToCopy += "Full Transcript:\n\n\(viewModel.currentTranscript)"
        
        #if os(iOS)
        UIPasteboard.general.string = textToCopy
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(textToCopy, forType: .string)
        #endif
    }
    
    #if os(iOS)
    private func shareTranscript() {
        var textToShare = ""
        
        if !viewModel.extractedKeywords.isEmpty {
            textToShare += "Keywords: \(viewModel.extractedKeywords.joined(separator: ", "))\n\n---\n\n"
        }
        
        if !viewModel.transcriptSummary.isEmpty && !viewModel.isGeneratingSummary {
            textToShare += "Summary:\n\n\(viewModel.transcriptSummary)\n\n---\n\n"
        }
        
        textToShare += "Full Transcript:\n\n\(viewModel.currentTranscript)"
        
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    #endif
}

// FlowLayout for wrapping keywords
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// Shimmer effect for loading animation
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.3), location: phase),
                        .init(color: .black, location: phase + 0.1),
                        .init(color: .black.opacity(0.3), location: phase + 0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview {
    let viewModel = ContentViewModel()
    viewModel.currentTranscript = "This is a sample transcript of what was said during the recording. It contains multiple sentences to demonstrate how the transcript view will look with real content."
    viewModel.extractedKeywords = ["Recording", "Sample", "Content", "Transcript", "View"]
    return TranscriptSummaryView(viewModel: viewModel)
}
