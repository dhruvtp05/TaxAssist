//
//  HomeScreen.swift
//  TaxAssist
//

import SwiftUI
import FirebaseAuth

// MARK: - Models

struct ActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let title: String
    let subtitle: String
}

enum TaxDocument: String, Identifiable {
    case w2 = "Form W-2"
    case form1099 = "Form 1099-NEC"
    
    var id: String { self.rawValue }
    
    var subtitle: String {
        switch self {
        case .w2: return "Wage and Tax Statement"
        case .form1099: return "Nonemployee Compensation"
        }
    }
}

// MARK: - Home Screen

struct HomeScreen: View {
    // Dynamic Firebase Data
    @State private var userName: String = "User"
    
    // UI State
    @State private var hasActiveDocument: Bool = false
    @State private var showFormSelector: Bool = false
    
    // This tracks which form the user clicked in the popup
    @State private var selectedDocument: TaxDocument?
    
    // Controls presenting the Tax Dictionary screen
    @State private var showTaxDictionary: Bool = false
    
    // Placeholder data for when a document IS active
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
                   subtitle: "View your currently completed documents ready for submission"),
        ActionItem(icon: "speaker.wave.2.fill",
                   iconColor: .purple,
                   iconBackground: Color.purple.opacity(0.12),
                   title: "Accessibility Settings",
                   subtitle: "Configure your preferences."),
        ActionItem(icon: "lightbulb.fill",
                   iconColor: .orange,
                   iconBackground: Color.orange.opacity(0.15),
                   title: "Tax Dictionary",
                   subtitle: "Get simple explanations for confusing tax terms.")
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
            .onAppear {
                fetchUserData()
            }
            .sheet(isPresented: $showFormSelector) {
                AvailableFormsSheet(selectedDocument: $selectedDocument)
            }
            .sheet(isPresented: $showTaxDictionary) {
                TaxDictionary()
            }
            .navigationDestination(item: $selectedDocument) { document in
                switch document {
                case .w2:
                    W2Form()
                        .toolbar(.hidden, for: .tabBar)
                case .form1099:
                    _099Form()
                        .toolbar(.hidden, for: .tabBar)
                }
            }
        }
    }

    // MARK: - Firebase Fetch
    
    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        if let displayName = user.displayName, !displayName.isEmpty {
            userName = displayName.components(separatedBy: " ").first ?? displayName
        } else if let email = user.email {
            userName = email.components(separatedBy: "@").first ?? "User"
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

    // MARK: Progress / Empty State Card
    
    @ViewBuilder
    private var returnProgressCard: some View {
        if hasActiveDocument {
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
            
        } else {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ready to file?")
                            .font(.title3.bold())
                        Text("Begin by adding your first tax document.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 38))
                        .foregroundColor(Color(uiColor: .systemGray4))
                }

                Button(action: {
                    showFormSelector = true
                }) {
                    HStack {
                        Text("Start a Document")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "plus")
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
    }

    // MARK: Action Grid

    private var actionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
            ForEach(actions) { action in
                if action.title == "FAQs" {
                    NavigationLink(destination: FAQs()) {
                        ActionCard(item: action)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        handleActionTap(action)
                    } label: {
                        ActionCard(item: action)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Action Grid Routing

    private func handleActionTap(_ action: ActionItem) {
        switch action.title {
        case "Tax Dictionary":
            showTaxDictionary = true
        case "My Documents":
            // TODO: hook up MyDocumentsScreen
            break
        case "Accessibility Settings":
            // TODO: hook up Accessibility Settings
            break
        default:
            break
        }
    }
}

// MARK: - Action Card

struct ActionCard: View {
    let item: ActionItem

    var body: some View {
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
        .frame(height: 180, alignment: .top)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - The Form Selector Popup Screen

struct AvailableFormsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedDocument: TaxDocument?
    
    let forms: [TaxDocument] = [.w2, .form1099]
    
    var body: some View {
        NavigationStack {
            List(forms) { form in
                Button(action: {
                    selectedDocument = form
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(form.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(form.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Select a Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
// MARK: - Preview

#Preview {
    HomeScreen()
}