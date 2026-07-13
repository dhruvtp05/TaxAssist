//
//  MainAppView.swift
//  TaxAssist
//

import SwiftUI

struct MainAppView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .home:
                    HomeScreen(selectedTab: $selectedTab)
                case .documents:
                    MyDocumentsScreen()
                case .chat:
                    Text("Chat Bot Coming Soon") // Placeholder
                        .font(.title).foregroundColor(.secondary)
                case .settings:
                    Text("Settings Coming Soon") // Placeholder
                        .font(.title).foregroundColor(.secondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 70)
            }

            VStack {
                Spacer()
                BottomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainAppView()
}
