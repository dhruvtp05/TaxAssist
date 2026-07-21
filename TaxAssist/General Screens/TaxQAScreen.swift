//
//  TaxQAScreen.swift
//  TaxAssist
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - User Interface
struct TaxQAScreen: View {
    @AppStorage("customBackgroundPreset") private var customBackgroundPreset: String = "white"
    @AppStorage("customTextHue") private var customTextHue: Double = 0.58
    @AppStorage("accessibilityLargerText") private var accessibilityLargerText: Bool = false
    @AppStorage("accessibilityBoldText") private var accessibilityBoldText: Bool = false
    @AppStorage("accessibilityReduceMotion") private var accessibilityReduceMotion: Bool = false
    @AppStorage("accessibilityConciseLabels") private var accessibilityConciseLabels: Bool = true

    @StateObject private var viewModel = ChatbotTaxQAViewModel()
    
    private var customBackgroundColor: Color {
        switch customBackgroundPreset {
        case "blue": return Color.blue.opacity(0.15)
        case "black": return Color.black.opacity(0.9)
        case "sky": return Color(red: 0.75, green: 0.88, blue: 1.0)
        default: return .white
        }
    }
    private var contrastingForegroundColor: Color {
        #if canImport(UIKit)
        let ui = UIColor(customBackgroundColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
            return luminance < 0.5 ? .white : .black
        } else {
            var white: CGFloat = 0
            ui.getWhite(&white, alpha: nil)
            return white < 0.5 ? .white : .black
        }
        #else
        return .primary
        #endif
    }
    private var customTextColor: Color {
        #if canImport(UIKit)
        let base = Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
        let fg = UIColor(contrastingForegroundColor)
        let bs = UIColor(base)
        var fr: CGFloat = 0, fgG: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        bs.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        fg.getRed(&fr, green: &fgG, blue: &fb, alpha: &fa)
        let mix: (CGFloat, CGFloat) -> CGFloat = { (u, c) in min(max(u * 0.75 + c * 0.25, 0), 1) }
        let rr = mix(br, fr), gg = mix(bg, fgG), bb2 = mix(bb, fb)
        return Color(red: rr, green: gg, blue: bb2)
        #else
        return Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
        #endif
    }
    
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
                                MessageBubble(text: message.prompt, isUser: true, accent: customTextColor)
                                    .id(message.id + "prompt")
                                
                                if let response = message.response {
                                    MessageBubble(text: response, isUser: false, accent: customTextColor)
                                        .id(message.id + "response")
                                } else {
                                    TypingIndicatorBubble(accent: customTextColor)
                                        .id(message.id + "typing")
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            if accessibilityReduceMotion {
                                proxy.scrollTo(lastMessage.response == nil ? lastMessage.id + "typing" : lastMessage.id + "response", anchor: .bottom)
                            } else {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.response == nil ? lastMessage.id + "typing" : lastMessage.id + "response", anchor: .bottom)
                                }
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
                            .foregroundColor(viewModel.inputText.isEmpty ? .gray : customTextColor)
                    }
                    .disabled(viewModel.inputText.isEmpty)
                }
                .padding()
                .padding(.bottom, 90)
                .background(Color(uiColor: .systemBackground))
            }
            .dynamicTypeSize(accessibilityLargerText ? .accessibility3 : .large)
            .background(customBackgroundColor.ignoresSafeArea())
            .navigationTitle(accessibilityConciseLabels ? "Assistant" : "Tax Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(customBackgroundColor, for: .navigationBar)
            .toolbarColorScheme(contrastingForegroundColor == .white ? .dark : .light, for: .navigationBar)
            .onAppear { viewModel.startListening() }
            .onDisappear { viewModel.stopListening() }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(customTextColor)
                .padding(.top, 40)
            Text("How can I help?")
                .font(.title2.bold())
                .foregroundStyle(customTextColor)
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
    let accent: Color
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(text)
                .padding(14)
                .background(isUser ? accent : Color(uiColor: .systemBackground))
                .foregroundColor(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(isUser ? 0 : 0.05), radius: 5, y: 2)
            
            if !isUser { Spacer() }
        }
    }
}

// MARK: - "AI is typing..." Component
struct TypingIndicatorBubble: View {
    let accent: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Circle().frame(width: 6, height: 6).opacity(0.4)
                Circle().frame(width: 6, height: 6).opacity(0.6)
                Circle().frame(width: 6, height: 6).opacity(0.8)
            }
            .padding(16)
            .background(Color(uiColor: .systemBackground))
            .foregroundColor(accent)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            
            Spacer()
        }
    }
}

#Preview {
    TaxQAScreen()
}
