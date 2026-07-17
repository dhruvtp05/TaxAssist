import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()
                Text("Last updated: ") + Text(Date(), style: .date)
                    .foregroundStyle(.secondary)

                Text("This is a placeholder for your Privacy Policy. Replace this text with your actual policy content. You can include details about data collection, usage, storage, and user rights.")
                    .font(.body)

                Text("Contact")
                    .font(.headline)
                Text("If you have any questions about this Privacy Policy, contact us at support@example.com.")
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { PrivacyPolicyView() }
}
