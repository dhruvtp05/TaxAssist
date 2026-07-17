import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .bold()
                Text("Please read these terms and conditions carefully before using this app.")
                    .foregroundStyle(.secondary)

                Group {
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By using TaxAssist, you agree to be bound by these Terms of Service. If you disagree with any part, you may not access the app.")
                    Text("2. Use of the Service")
                        .font(.headline)
                    Text("You agree to use the app in compliance with all applicable laws and regulations.")
                    Text("3. Disclaimer")
                        .font(.headline)
                    Text("This app provides general information and does not constitute legal or tax advice. Consult a professional for advice specific to your situation.")
                }

                Text("Contact")
                    .font(.headline)
                Text("If you have any questions about these Terms, contact us at support@example.com.")
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { TermsOfServiceView() }
}
