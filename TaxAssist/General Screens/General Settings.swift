//
//  General Settings.swift
//  TaxAssist
//
//  Created by SandboxLab on 7/14/26.
//

import SwiftUI
struct GeneralSettingsView: View {
    // MARK: - State
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("marketingEmails") private var marketingEmails: Bool = false
    @AppStorage("appearance") private var appearance: Appearance = .system
    @State private var isMFAEnabled: Bool = true
    @AppStorage("tintColorName") private var tintColorName: String = "Blue"

    enum Appearance: String, CaseIterable, Identifiable, Codable {
        case system, light, dark
        var id: String { rawValue }
        var label: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
    }
    
    private var tintColor: Color {
        switch tintColorName {
        case "Blue": return .blue
        case "Green": return .green
        case "Orange": return .orange
        case "Purple": return .purple
        case "Red": return .red
        case "Teal": return .teal
        default: return .accentColor
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section(header: Text("Account")) {
                    NavigationLink {
                        ProfileDetailsView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill").foregroundStyle(.blue)
                            VStack(alignment: .leading) {
                                Text("Profile")
                                Text("Name, email, and contact info")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    NavigationLink {
                        TaxProfileView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass").foregroundStyle(.green)
                            VStack(alignment: .leading) {
                                Text("Tax Profile")
                                Text("Filing status, dependents, and address")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Security
                Section(header: Text("Security")) {
                    Toggle(isOn: $isMFAEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill").foregroundStyle(.purple)
                            VStack(alignment: .leading) {
                                Text("Two-Factor Authentication")
                                Text("Add an extra layer of security")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    NavigationLink {
                        PasswordSettingsView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "key.fill").foregroundStyle(.orange)
                            VStack(alignment: .leading) {
                                Text("Password")
                                Text("Change your password")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Notifications
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.badge.fill").foregroundStyle(.red)
                            VStack(alignment: .leading) {
                                Text("Enable Notifications")
                                Text("Reminders for deadlines and updates")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    Toggle(isOn: $marketingEmails) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill").foregroundStyle(.teal)
                            VStack(alignment: .leading) {
                                Text("Marketing Emails")
                                Text("Get tips and occasional promotions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Appearance
                Section(header: Text("Appearance")) {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(Appearance.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    Picker("Accent Color", selection: $tintColorName) {
                        Text("Blue").tag("Blue")
                        Text("Green").tag("Green")
                        Text("Orange").tag("Orange")
                        Text("Purple").tag("Purple")
                        Text("Red").tag("Red")
                        Text("Teal").tag("Teal")
                    }
                }

                // About
                Section(header: Text("About"), footer: Text("Version 1.0.0\n© 2026 TaxAssist, Inc.").font(.caption).foregroundStyle(.secondary)) {
                    NavigationLink {
                        LicensesView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.plaintext").foregroundStyle(.gray)
                            Text("Licenses")
                        }
                    }
                    NavigationLink {
                        LocalPrivacyPolicyView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill").foregroundStyle(.pink)
                            Text("Privacy Policy")
                        }
                    }
                    NavigationLink {
                        LocalTermsOfServiceView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.fill").foregroundStyle(.indigo)
                            Text("Terms of Service")
                        }
                    }
                }

                // Sign out
                Section {
                    Button(role: .destructive) {
                        // TODO: Wire to FirebaseAuth sign out
                        // try? Auth.auth().signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
            }
            .tint(tintColor)
            .preferredColorScheme(appearance == .system ? nil : (appearance == .light ? .light : .dark))
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Subviews / Placeholders

struct ProfileDetailsView: View {
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                Text("First Name")
                Text("Last Name")
            }
            Section(header: Text("Contact")) {
                Text("Email")
                Text("Phone")
            }
        }
        .navigationTitle("Profile")
    }
}

struct TaxProfileView: View {
    var body: some View {
        Form {
            Section(header: Text("Filing Status")) {
                Text("Single")
            }
            Section(header: Text("Dependents")) {
                Text("0")
            }
            Section(header: Text("Address")) {
                Text("Street, City, State")
            }
        }
        .navigationTitle("Tax Profile")
    }
}

struct PasswordSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Change Password")) {
                SecureField("Current Password", text: .constant(""))
                SecureField("New Password", text: .constant(""))
                SecureField("Confirm New Password", text: .constant(""))
                Button("Update Password") {}
            }
        }
        .navigationTitle("Password")
    }
}

struct LicensesView: View {
    var body: some View {
        ScrollView {
            Text("Open source licenses will appear here.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle("Licenses")
    }
}

fileprivate struct LocalPrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("1. Information We Collect")
                        .font(.headline)
                    Text("To provide our services, we collect your email address for account authentication. We also collect the personal and financial information you voluntarily input into our questionnaires. This may include income, expenses, and demographic data required to complete your tax forms.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Group {
                    Text("2. How We Use Your Data")
                        .font(.headline)
                    Text("Your data is used strictly for core app functionality: maintaining your account and generating your PDF tax forms. We do not use your financial information for marketing, nor do we use it for targeted advertising.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Group {
                    Text("3. Data Sharing & Third Parties")
                        .font(.headline)
                    Text("We absolutely do not sell, rent, or trade your personal or financial data. We utilize trusted third-party cloud services (such as Google Firebase) solely to securely store and process your data. These providers are bound by strict confidentiality and security standards.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Group {
                    Text("4. Data Security")
                        .font(.headline)
                    Text("We implement industry-standard security measures, including data encryption in transit and at rest, to protect your sensitive information. However, no electronic transmission or storage system is 100% secure, and we cannot guarantee absolute security.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider().padding(.vertical, 8)

                Group {
                    Text("5. Account Deletion")
                        .font(.headline)
                    Text("You have the right to request the deletion of your account and all associated tax data at any time. You can do this directly within the app settings or by contacting our support team.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

fileprivate struct LocalTermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By creating an account or using Tax Assist, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Group {
                    Text("2. No Professional Tax Advice")
                        .font(.headline)
                    Text("Tax Assist provides software tools to help format and generate PDF tax forms based solely on user inputs. Tax Assist is NOT a Certified Public Accountant (CPA), financial advisor, or tax attorney. We do not provide tax, legal, or financial advice. You are solely responsible for verifying the accuracy of your forms before filing them with the IRS or state tax authorities.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Group {
                    Text("3. User Responsibilities & Accuracy")
                        .font(.headline)
                    Text("The accuracy of the generated tax documents relies entirely on the information you provide. Tax Assist is not liable for any audits, penalties, fines, or delayed returns resulting from incorrect or incomplete information entered into the application.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Group {
                    Text("4. Account Security")
                        .font(.headline)
                    Text("You are responsible for maintaining the confidentiality of your login credentials. Tax Assist reserves the right to suspend or terminate accounts that engage in fraudulent activity or violate these terms.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider().padding(.vertical, 8)

                Group {
                    Text("5. Limitation of Liability")
                        .font(.headline)
                    Text("To the maximum extent permitted by law, Tax Assist and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

#Preview {
    GeneralSettingsView()
}
