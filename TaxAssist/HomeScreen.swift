//
//  HomeScreen.swift
//  TaxAssist
//
//  Created by SandboxLab on 7/6/26.
//

import SwiftUI

// MARK: - Model

struct ActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let title: String
    let subtitle: String
}

// MARK: - Home Screen

struct HomeScreen: View {
    let userName: String = "Alex"
    let currentStep: Int = 2
    let totalSteps: Int = 10

    private var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    private let actions: [ActionItem] = [
        ActionItem(icon: "bubble.left.fill",
                   iconColor: .blue,
                   iconBackground: Color.blue.opacity(0.12),
                   title: "FAQs",
                   subtitle: "Get instant answers to frequently asked tax questions."),
        ActionItem(icon: "viewfinder",
                   iconColor: .green,
                   iconBackground: Color.green.opacity(0.12),
                   title: "My Documents",
                   subtitle: "View your currentl completed documents ready for submission"),
        ActionItem(icon: "speaker.wave.2.fill",
                   iconColor: .purple,
                   iconBackground: Color.purple.opacity(0.12),
                   title: "Accessability Settings",
                   subtitle: "Configure your preferences."),
        ActionItem(icon: "lightbulb.fill",
                   iconColor: .orange,
                   iconBackground: Color.orange.opacity(0.15),
                   title: "Tax Dictionary",
                   subtitle: "Get simple explinatinos for confusing tax terms.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    greeting

                    returnProgressCard

                    Text("What would you like to do?")
                        .font(.title2.bold())
                        .foregroundColor(.primary)

                    actionGrid

                    securityBanner
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                BottomTabBar()
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2.5)
                        .frame(width: 40, height: 40)
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                }

                Text("\(Text("Tax").foregroundColor(.primary))\(Text("Assist").foregroundColor(.blue))")
                    .font(.title.bold())
            }

            Spacer()

            Image(systemName: "person.circle")
                .font(.system(size: 30))
                .foregroundColor(.blue)
        }
    }

    // MARK: Greeting

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Good morning, \(userName)!")
                .font(.system(size: 28, weight: .bold))
            Text("Let's get your taxes done, step by step.")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    // MARK: Progress Card

    private var returnProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("2024 Tax Return")
                        .font(.title3.bold())
                    Text("Step \(currentStep) of \(totalSteps)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 34))
                        .foregroundColor(Color(uiColor: .systemGray4))

                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 6, y: 6)
                }
            }

            HStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 8)
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: geo.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(Int(progress * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
            }

            Button(action: {}) {
                HStack {
                    Text("Continue Filing")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: Action Grid

    private var actionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
            ForEach(actions) { action in
                ActionCard(item: action)
            }
        }
    }

    // MARK: Security Banner

    private var securityBanner: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 26))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Your information is safe with us")
                    .font(.headline)
                Text("We use bank-level encryption to keep your data secure and private.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color.blue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

}

// MARK: - Action Card

struct ActionCard: View {
    let item: ActionItem

    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(item.iconBackground)
                        .frame(width: 48, height: 48)
                    Image(systemName: item.icon)
                        .font(.system(size: 20))
                        .foregroundColor(item.iconColor)
                }

                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                HStack(alignment: .bottom) {
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 160, alignment: .top)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    HomeScreen()
}
