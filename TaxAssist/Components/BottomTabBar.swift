//
//  BottomTabBar.swift
//  TaxAssist
//

import SwiftUI

struct BottomTabBar: View {
    var body: some View {
        bottomTabBar
    }

    private var bottomTabBar: some View {
        HStack {
            TabBarItem(icon: "house.fill", title: "Home", isSelected: true)
            Spacer()
            TabBarItem(icon: "folder.fill", title: "My Documents", isSelected: false)
            Spacer()
            TabBarItem(icon: "bubble.left.and.bubble.right.fill", title: "Chat Bot", isSelected: false)
            Spacer()
            TabBarItem(icon: "gearshape.fill", title: "Settings", isSelected: false)
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
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22))
            Text(title)
                .font(.caption2)
        }
        .foregroundColor(isSelected ? .blue : .secondary)
    }
}

#Preview {
    BottomTabBar()
}
