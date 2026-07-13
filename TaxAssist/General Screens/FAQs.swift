//
//  FAQs.swift
//  TaxAssist
//
//  Created by SandboxLab on 7/13/26.
//

import SwiftUI

struct FAQs: View {
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    Text("Last Updated: July 2026")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                
                HStack {
                    Spacer()
                    Text("FAQs")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                
                Section(header: Text("Getting Started")) {
                    DisclosureGroup("Is My Data Secure?") {
                        Text("Yes. We use industry-standard encryption in transit and at rest. You can also enable multi-factor authentication (MFA) in Settings for an extra layer of security.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                }

                Section(header: Text("Using TaxAssist")) {
                    DisclosureGroup("What documents should I prepare?") {
                        Text("Common items include W-2s, 1099s, prior-year return, receipts for deductions, and records of charitable donations, mortgage interest, or education expenses.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                    DisclosureGroup("Can I import last year’s taxes?") {
                        Text("If you filed with us previously, we’ll prefill your profile automatically. You can also upload a PDF of last year’s return to help prefill some fields.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                    DisclosureGroup("How do I track my refund?") {
                        Text("After filing, go to Home > Filing Status. We show your e-file status and a link to the IRS/State refund tracker with your details prefilled.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                }

                Section(header: Text("Billing & Plans")) {
                    DisclosureGroup("How much does it cost?") {
                        Text("Pricing depends on the complexity of your return (simple, itemized, self‑employed). You’ll always see the price before you file, and you won’t be charged until you submit.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                    DisclosureGroup("Do you offer state returns?") {
                        Text("Yes. State returns are available for most states. State pricing is shown separately and added at checkout if selected.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                    DisclosureGroup("What is your refund policy?") {
                        Text("If you experience an issue that prevents filing or leads to incorrect calculation due to our error, contact support within 30 days and we’ll make it right.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                }

                Section(header: Text("Support")) {
                    DisclosureGroup("How can I contact support?") {
                        Text("Open Settings > Help & Support to chat with us or send an email. Our typical response time is under 24 hours during peak season.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                    DisclosureGroup("Do you have human tax experts?") {
                        Text("Yes. You can request an expert review before filing. Availability and pricing vary by plan and complexity.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

#Preview {
    FAQs()
}
