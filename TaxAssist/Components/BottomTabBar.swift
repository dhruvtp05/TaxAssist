//
//  BottomTabBar.swift
//  TaxAssist
//

import SwiftUI

enum Tab {
    case home
    case documents
    case chat
    case settings
}

struct BottomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            TabBarItem(icon: "house.fill", title: "Home", tab: .home, selectedTab: $selectedTab)
            Spacer()
            TabBarItem(icon: "folder.fill", title: "My Documents", tab: .documents, selectedTab: $selectedTab)
            Spacer()
            TabBarItem(icon: "bubble.left.and.bubble.right.fill", title: "Chat Bot", tab: .chat, selectedTab: $selectedTab)
            Spacer()
            TabBarItem(icon: "gearshape.fill", title: "Settings", tab: .settings, selectedTab: $selectedTab)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(
            Color(uiColor: .systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 6, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

private struct TabBarItem: View {
    let icon: String
    let title: String
    let tab: Tab
    @Binding var selectedTab: Tab

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(selectedTab == tab ? .blue : .secondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BottomTabBar(selectedTab: .constant(.home))
}
