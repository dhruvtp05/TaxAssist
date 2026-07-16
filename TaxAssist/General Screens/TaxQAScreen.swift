//
//  TaxQAScreen.swift
//  TaxAssist
//

import SwiftUI

// MARK: - User Interface
struct TaxQAScreen: View {
    @StateObject private var viewModel = ChatbotTaxQAViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.messages.isEmpty {
                                emptyStateView
                            }
                            
                            ForEach(viewModel.messages) { message in
                                MessageBubble(text: message.prompt, isUser: true)
                                    .id(message.id + "prompt")
                                
                                if let response = message.response {
                                    MessageBubble(text: response, isUser: false)
                                        .id(message.id + "response")
                                } else {
                                    TypingIndicatorBubble()
                                        .id(message.id + "typing")
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.response == nil ? lastMessage.id + "typing" : lastMessage.id + "response", anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("Ask a tax question...", text: $viewModel.inputText, axis: .vertical)
                        .padding(12)
                        .background(Color(uiColor: .systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .lineLimit(1...5)
                    
                    Button {
                        viewModel.sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(viewModel.inputText.isEmpty ? .gray : .blue)
                    }
                    .disabled(viewModel.inputText.isEmpty)
                }
                .padding()
                .padding(.bottom, 90)
                .background(Color(uiColor: .systemBackground))
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Tax Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.startListening() }
            .onDisappear { viewModel.stopListening() }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .padding(.top, 40)
            Text("How can I help?")
                .font(.title2.bold())
            Text("Ask me anything about related to your taxes")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Chat Bubble Component
struct MessageBubble: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(text)
                .padding(14)
                .background(isUser ? Color.blue : Color(uiColor: .systemBackground))
                .foregroundColor(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(isUser ? 0 : 0.05), radius: 5, y: 2)
            
            if !isUser { Spacer() }
        }
    }
}

// MARK: - "AI is typing..." Component
struct TypingIndicatorBubble: View {
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Circle().frame(width: 6, height: 6).opacity(0.4)
                Circle().frame(width: 6, height: 6).opacity(0.6)
                Circle().frame(width: 6, height: 6).opacity(0.8)
            }
            .padding(16)
            .background(Color(uiColor: .systemBackground))
            .foregroundColor(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            
            Spacer()
        }
    }
}

#Preview {
    TaxQAScreen()
}
