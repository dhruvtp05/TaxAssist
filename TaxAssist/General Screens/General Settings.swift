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

struct GeneralSettingsView: View {
    // Persistent settings using AppStorage
    @AppStorage("userFullName") private var userFullName: String = ""
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    @AppStorage("defaultTaxYear") private var defaultTaxYear: Int = Calendar.current.component(.year, from: Date())
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("reminderDayOfMonth") private var reminderDayOfMonth: Int = 15
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled: Bool = false
    @AppStorage("shareAnalytics") private var shareAnalytics: Bool = false
    @AppStorage("customBackgroundPreset") private var customBackgroundPreset: String = "white" // presets: white, blue, black, sky
    @AppStorage("customTextHue") private var customTextHue: Double = 0.58 // 0...1
    
    // Derived color from preset
    private var customBackgroundColor: Color {
        switch customBackgroundPreset {
        case "blue":
            return Color.blue.opacity(0.15)
        case "black":
            return Color.black.opacity(0.9)
        case "sky":
            return Color(red: 0.75, green: 0.88, blue: 1.0) // sky blue
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
    
    // Local-only state (ephemeral)
    @State private var isExportingData: Bool = false
    @State private var exportStatusMessage: String?
    @State private var showingResetConfirmation: Bool = false
    @State private var emailError: String? = nil
    
    private let supportedCurrencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "INR", "CHF"]
    private let supportedTaxYears: [Int] = {
        let current = Calendar.current.component(.year, from: Date())
        // Offer a range of recent and near-future years
        return Array((current - 5)...(current + 1)).reversed()
    }()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header:
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                ) {
                    HStack(spacing: 10) {
                        Image(systemName: "person").foregroundStyle(customTextColor)
                        TextField("Full name", text: $userFullName)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "envelope").foregroundStyle(customTextColor)
                        TextField("Email", text: $userEmail)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    
                    if let emailError {
                        Text(emailError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .textCase(nil)
                .onChange(of: userEmail) { newValue in
                    let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
                    let isValid = newValue.uppercased().range(of: pattern, options: .regularExpression) != nil
                    emailError = isValid || newValue.isEmpty ? nil : "Please enter a valid email address."
                }
                
                Section(header:
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape")
                        Text("Preferences")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor),
                        footer: Text("Currency affects reports and input defaults. Tax year sets the default context for new entries.")
                ) {
                    Picker(selection: $preferredCurrency) {
                        ForEach(supportedCurrencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "dollarsign.circle").foregroundStyle(customTextColor)
                            Text("Currency")
                        }
                    }
                    
                    Picker(selection: $defaultTaxYear) {
                        ForEach(supportedTaxYears, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "calendar").foregroundStyle(customTextColor)
                            Text("Default tax year")
                        }
                    }
                }
                .textCase(nil)
                
                Section(header:
                    HStack(spacing: 8) {
                        Image(systemName: "paintpalette")
                        Text("Appearance")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                ) {
                    Picker("Background", selection: $customBackgroundPreset) {
                        Text("White").tag("white")
                        Text("Blue").tag("blue")
                        Text("Dark Black").tag("black")
                        Text("Sky Blue").tag("sky")
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Text hue")
                            Spacer()
                            Circle()
                                .fill(customTextColor)
                                .frame(width: 18, height: 18)
                                .overlay(Circle().stroke(.secondary.opacity(0.3), lineWidth: 1))
                                .accessibilityHidden(true)
                        }
                        Slider(value: $customTextHue, in: 0...1, step: 0.01)
                            .tint(customTextColor)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Text hue")
                    
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(customBackgroundColor)
                        .overlay(
                            HStack(spacing: 12) {
                                Circle().fill(customTextColor).frame(width: 12, height: 12)
                                Text("Preview text")
                                    .foregroundStyle(customTextColor)
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(customTextColor.opacity(0.15), lineWidth: 1)
                        )
                        .frame(height: 56)
                        .listRowBackground(customBackgroundColor)
                }
                .textCase(nil)
                
                Section(header:
                    HStack(spacing: 8) {
                        Image(systemName: "bell.badge")
                        Text("Notifications")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor),
                        footer: Text("Reminders are sent on the selected day each month when notifications are enabled.")
                ) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable notifications").foregroundStyle(customTextColor)
                    }
                    
                    if notificationsEnabled {
                        Picker(selection: $reminderDayOfMonth) {
                            ForEach(1..<29) { day in
                                Text("Day \(day)").tag(day)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "calendar.badge.clock").foregroundStyle(customTextColor)
                                Text("Reminder day")
                            }
                        }
                        .accessibilityHint("Choose a day of the month to receive a reminder")
                    }
                }
                .textCase(nil)
                
                Section(header:
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield")
                        Text("Data & Privacy")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor),
                        footer: Text("We value your privacy. Analytics are anonymous and help us improve TaxAssist.")
                ) {
                    Toggle(isOn: $biometricLockEnabled) {
                        Text("Require Face ID / Touch ID").foregroundStyle(customTextColor)
                    }
                    
                    Toggle(isOn: $shareAnalytics) {
                        Text("Share anonymous analytics").foregroundStyle(customTextColor)
                    }
                    
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            Text("Export data")
                            Spacer()
                            if isExportingData {
                                ProgressView()
                            }
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
                    
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Text("Reset all settings")
                    }
                    .confirmationDialog("Reset all settings?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
                        Button("Reset", role: .destructive) {
                            resetAllSettings()
                            #if canImport(UIKit)
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            #endif
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will restore all settings to their defaults. This action cannot be undone.")
                    }
                }
                .textCase(nil)
                
                Section(header:
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle")
                        Text("Support")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                ) {
                    Button {
                        rateApp()
                    } label: {
                        Label("Rate TaxAssist", systemImage: "star.circle")
                            .foregroundStyle(customTextColor)
                    }
                    
                    Button {
                        contactSupport()
                    } label: {
                        Label("Contact support", systemImage: "envelope")
                            .foregroundStyle(customTextColor)
                    }
                }
                .textCase(nil)
                
                Section(header:
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                        Text("Legal")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                ) {
                    NavigationLink(destination: PrivacyPolicyScreen()) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundStyle(customTextColor)
                    }
                    NavigationLink(destination: TermsOfServiceScreen()) {
                        Label("Terms of Service", systemImage: "doc.plaintext")
                            .foregroundStyle(customTextColor)
                    }
                }
                .textCase(nil)
                
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                            .foregroundStyle(customTextColor)
                        Spacer()
                        Text(appVersionString)
                            .foregroundStyle(.secondary)
                    }
                }
                .textCase(nil)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(customBackgroundColor.ignoresSafeArea())
            .foregroundStyle(customTextColor)
            .toolbarBackground(customBackgroundColor, for: .navigationBar)
            .toolbarColorScheme(contrastingForegroundColor == .white ? .dark : .light, for: .navigationBar)
            // Apply foreground style on platforms where available; iOS doesn't support toolbarForegroundStyle
            #if os(macOS) || os(visionOS)
            .toolbarForegroundStyle(customTextColor, for: .navigationBar)
            #endif
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .tint(customTextColor)
        }
    }
}

// MARK: - Helpers
private extension GeneralSettingsView {
    var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
    
    func exportData() {
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
    
    func resetAllSettings() {
        userFullName = ""
        userEmail = ""
        preferredCurrency = "USD"
        defaultTaxYear = Calendar.current.component(.year, from: Date())
        notificationsEnabled = true
        reminderDayOfMonth = 15
        biometricLockEnabled = false
        shareAnalytics = false
    }
    
    func rateApp() {
        // Hook up StoreKit requestReview or deep link to App Store when available.
        // For now this is a placeholder.
        #if DEBUG
        print("Rate app tapped")
        #endif
    }
    
    func contactSupport() {
        // Hook up email composer or in-app support flow.
        // For now this is a placeholder.
        #if DEBUG
        print("Contact support tapped")
        #endif
    }
}

// MARK: - Preview
#Preview {
    GeneralSettingsView()
}

