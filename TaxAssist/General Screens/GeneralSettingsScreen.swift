//
//  General Settings.swift
//  TaxAssist
//
//  Created by SandboxLab on 7/16/26.
//

import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

enum SettingsUI {
    struct GeneralSettingsScreen: View {
        // Persistent settings using AppStorage
        @AppStorage("userFullName") private var userFullName: String = ""
        @AppStorage("userEmail") private var userEmail: String = ""
        @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
        @AppStorage("defaultTaxYear") private var defaultTaxYear: Int = Calendar.current.component(.year, from: Date())
        @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
        @AppStorage("reminderDayOfMonth") private var reminderDayOfMonth: Int = 15
        @AppStorage("biometricLockEnabled") private var biometricLockEnabled: Bool = false
        @AppStorage("shareAnalytics") private var shareAnalytics: Bool = false
        @AppStorage("customBackgroundPreset") private var customBackgroundPreset: String = "white" // presets: white, blue, black
        @AppStorage("customTextHue") private var customTextHue: Double = 0.58 // 0...1
        
        @AppStorage("accessibilityLargerText") private var accessibilityLargerText: Bool = false
        @AppStorage("accessibilityBoldText") private var accessibilityBoldText: Bool = false
        
        // Derived color from preset
        private var customBackgroundColor: Color {
            switch customBackgroundPreset {
     
            case "black":
                return Color(red: 0.10, green: 0.11, blue: 0.12)
            default:
                return Color.white
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
                // Grayscale or non-RGB color space fallback
                var white: CGFloat = 0
                ui.getWhite(&white, alpha: nil)
                return white < 0.5 ? .white : .black
            }
            #else
            return .primary
            #endif
        }
        
        private var customTextColor: Color {
            // Create a color from the stored hue; keep high saturation but moderate brightness for legibility
            let base = Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
            #if canImport(UIKit)
            // Blend slightly toward the contrasting color to ensure minimum contrast
            let fg = UIColor(contrastingForegroundColor)
            let bs = UIColor(base)
            var fr: CGFloat = 0, fgG: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
            var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
            bs.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
            fg.getRed(&fr, green: &fgG, blue: &fb, alpha: &fa)
            // Weighted mix: mostly user hue, 25% contrasting to improve readability
            let mix: (CGFloat, CGFloat) -> CGFloat = { (u, c) in min(max(u * 0.75 + c * 0.25, 0), 1) }
            let rr = mix(br, fr), gg = mix(bg, fgG), bb2 = mix(bb, fb)
            return Color(red: rr, green: gg, blue: bb2)
            #else
            return base
            #endif
        }
        
        private var previewStrokeColor: Color {
            #if canImport(UIKit)
            let ui = UIColor(customBackgroundColor)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
                let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
                // On light backgrounds use a subtle gray; on dark backgrounds use translucent white
                return luminance >= 0.5 ? Color.black.opacity(0.12) : Color.white.opacity(0.22)
            } else {
                var white: CGFloat = 0
                ui.getWhite(&white, alpha: nil)
                return white >= 0.5 ? Color.black.opacity(0.12) : Color.white.opacity(0.32)
            }
            #else
            return Color.black.opacity(0.12)
            #endif
        }
        
        // Local-only state (ephemeral)
        @State private var isExportingData: Bool = false
        @State private var exportStatusMessage: String?
        @State private var showingResetConfirmation: Bool = false
        @State private var emailError: String? = nil
        @State private var query: String = ""

        private let supportedCurrencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "INR", "CHF"]
        private let supportedTaxYears: [Int] = {
            let current = Calendar.current.component(.year, from: Date())
            // Offer a range of recent and near-future years
            return Array((current - 5)...(current + 1)).reversed()
        }()
        
        var body: some View {
            NavigationStack {
                List {
                    // Search
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Search settings", text: $query)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                    }

                    // Account
                    Section(header: Text("Account").font(.subheadline).bold()) {
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 12) {
                                LabeledContent("Full name") {
                                    TextField("Full name", text: $userFullName)
                                        .multilineTextAlignment(.trailing)
                                        .textContentType(.name)
                                        .textInputAutocapitalization(.words)
                                        .autocorrectionDisabled()
                                }
                                Divider()
                                LabeledContent("Email") {
                                    TextField("Email", text: $userEmail)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.emailAddress)
                                        .textContentType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                                if let emailError {
                                    Text(emailError)
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                }
                                Spacer()
                            }
                            .padding()
                            .navigationTitle("Account Information")
                            .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle")
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Account Information").fontWeight(accessibilityBoldText ? .bold : .regular)
                                    Text(userEmail.isEmpty ? "Add email" : userEmail)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                        }

                        NavigationLink {
                            VStack(alignment: .leading, spacing: 16) {
                                Toggle(isOn: $biometricLockEnabled) {
                                    Text("Require Face ID / Touch ID")
                                }
                                Spacer()
                            }
                            .padding()
                            .navigationTitle("Security")
                            .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield")
                                    .foregroundStyle(.blue)
                                Text("Security").fontWeight(accessibilityBoldText ? .bold : .regular)
                                Spacer()
                                Text(biometricLockEnabled ? "On" : "Off")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        NavigationLink {
                            VStack(alignment: .leading, spacing: 16) {
                                Toggle(isOn: $notificationsEnabled) {
                                    Text("Enable notifications")
                                }
                                if notificationsEnabled {
                                    Picker("Reminder day", selection: $reminderDayOfMonth) {
                                        ForEach(1..<29) { day in
                                            Text("Day \(day)").tag(day)
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            .navigationTitle("Notifications")
                            .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.badge")
                                    .foregroundStyle(.blue)
                                Text("Notifications").fontWeight(accessibilityBoldText ? .bold : .regular)
                                Spacer()
                                Text(notificationsEnabled ? "On" : "Off")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .textCase(nil)
                    .onChange(of: userEmail) { newValue in
                        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
                        let isValid = newValue.uppercased().range(of: pattern, options: .regularExpression) != nil
                        emailError = isValid || newValue.isEmpty ? nil : "Please enter a valid email address."
                    }

                    // Preferences
                    Section(header: Text("Preferences").font(.subheadline).bold()) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .foregroundStyle(.blue)
                            Picker("Language", selection: .constant("English")) {
                                Text("English").tag("English")
                            }
                            .pickerStyle(.navigationLink)
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "dollarsign")
                                .foregroundStyle(.blue)
                            Picker("Currency", selection: $preferredCurrency) {
                                ForEach(supportedCurrencies, id: \.self) { code in
                                    Text(code).tag(code)
                                }
                            }
                            .pickerStyle(.navigationLink)
                            Spacer(minLength: 0)
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundStyle(.blue)
                            Picker("Default tax year", selection: $defaultTaxYear) {
                                ForEach(supportedTaxYears, id: \.self) { year in
                                    Text(String(year)).tag(year)
                                }
                            }
                            .pickerStyle(.navigationLink)
                            Spacer(minLength: 0)
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "paintpalette")
                                .foregroundStyle(.blue)
                            NavigationLink {
                                VStack(alignment: .leading, spacing: 16) {
                                    Picker("Background", selection: $customBackgroundPreset) {
                                        Text("Light").tag("white")
                                        Text("Dark").tag("black")
                                    }
                                    .pickerStyle(.segmented)

                                    VStack(alignment: .leading, spacing: 8) {
                                        LabeledContent("Accent hue") {
                                            Slider(value: $customTextHue, in: 0...1, step: 0.01)
                                        }
                                    }

                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.background)
                                        .overlay(
                                            HStack(spacing: 12) {
                                                Circle().fill(.tint).frame(width: 12, height: 12)
                                                Text("Preview text")
                                                    .font(.subheadline)
                                                Spacer()
                                            }
                                            .padding(12)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: 1)
                                        )
                                        .frame(height: 56)

                                    Spacer()
                                }
                                .padding()
                                .navigationTitle("Appearance")
                                .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                HStack {
                                    Text("Appearance").fontWeight(accessibilityBoldText ? .bold : .regular)
                                    Spacer()
                                    Text(customBackgroundPreset == "black" ? "Dark" : "Light")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .textCase(nil)

                    // General
                    Section(header: Text("General").font(.subheadline).bold()) {
                        Button {
                            exportData()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "externaldrive.badge.icloud")
                                    .foregroundStyle(.blue)
                                Text("Data & Storage").fontWeight(accessibilityBoldText ? .bold : .regular)
                                Spacer()
                                if isExportingData { ProgressView() }
                            }
                        }
                        .disabled(isExportingData)
                        .alert("Export", isPresented: Binding(get: {
                            exportStatusMessage != nil
                        }, set: { newValue in
                            if !newValue { exportStatusMessage = nil }
                        })) {
                            Button("OK", role: .cancel) { exportStatusMessage = nil }
                        } message: {
                            Text(exportStatusMessage ?? "")
                        }

                        Toggle(isOn: $shareAnalytics) {
                            HStack(spacing: 12) {
                                Image(systemName: "chart.bar.xaxis")
                                    .foregroundStyle(.blue)
                                Text("Share anonymous analytics")
                                    .fontWeight(accessibilityBoldText ? .bold : .regular)
                            }
                        }
                    }
                    .textCase(nil)

                    // Support
                    Section(header: Text("Support").font(.subheadline).bold()) {
                        NavigationLink {
                            PrivacyPolicyScreen()
                                .navigationTitle("Privacy Policy")
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "hand.raised")
                                    .foregroundStyle(.blue)
                                Text("Privacy Policy").fontWeight(accessibilityBoldText ? .bold : .regular)
                            }
                        }

                        NavigationLink {
                            TermsOfServiceScreen()
                                .navigationTitle("Terms of Service")
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.plaintext")
                                    .foregroundStyle(.blue)
                                Text("Terms of Service").fontWeight(accessibilityBoldText ? .bold : .regular)
                            }
                        }

                        Button {
                            rateApp()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "star.circle")
                                    .foregroundStyle(.blue)
                                Text("Help Center").fontWeight(accessibilityBoldText ? .bold : .regular)
                            }
                        }

                        Button {
                            contactSupport()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .foregroundStyle(.blue)
                                Text("Contact Support").fontWeight(accessibilityBoldText ? .bold : .regular)
                            }
                        }
                    }
                    .textCase(nil)

                    // App info
                    Section(footer: Text("Your settings are saved automatically and can be changed at any time.").font(.footnote).foregroundStyle(.secondary)) {
                        HStack {
                            Label { Text("Version").fontWeight(accessibilityBoldText ? .bold : .regular) } icon: {
                                Image(systemName: "info.circle")
                            }
                            Spacer()
                            Text(appVersionString)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .textCase(nil)

                    // Log out destructive
                    Section {
                        Button(role: .destructive) {
                            // Hook up actual sign-out when available
                        } label: {
                            HStack {
                                Spacer()
                                Text("Log Out")
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .dynamicTypeSize(accessibilityLargerText ? .accessibility3 : .large)
                .scrollContentBackground(.hidden)
                .background(customBackgroundColor.ignoresSafeArea())
                .toolbarBackground(customBackgroundColor, for: .navigationBar)
                .toolbarColorScheme(contrastingForegroundColor == .white ? .dark : .light, for: .navigationBar)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
        }

        // MARK: - Helpers
        private var appVersionString: String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
            return "\(version) (\(build))"
        }
        
        private func exportData() {
            // Simulated export work; replace with real export logic as needed.
            guard !isExportingData else { return }
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            isExportingData = true
            exportStatusMessage = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                #if canImport(UIKit)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                #endif
                isExportingData = false
                exportStatusMessage = "Your data export has been prepared successfully."
            }
        }
        
        private func resetAllSettings() {
            userFullName = ""
            userEmail = ""
            preferredCurrency = "USD"
            defaultTaxYear = Calendar.current.component(.year, from: Date())
            notificationsEnabled = true
            reminderDayOfMonth = 15
            biometricLockEnabled = false
            shareAnalytics = false
        }
        
        private func rateApp() {
            // Hook up StoreKit requestReview or deep link to App Store when available.
            // For now this is a placeholder.
            #if DEBUG
            print("Rate app tapped")
            #endif
        }
        
        private func contactSupport() {
            // Hook up email composer or in-app support flow.
            // For now this is a placeholder.
            #if DEBUG
            print("Contact support tapped")
            #endif
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsUI.GeneralSettingsScreen()
}

