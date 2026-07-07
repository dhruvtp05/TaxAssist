//
//  PrivacyPolicyScreen.swift
//  TaxAssist
//
//  Created by Dhruv Patel on 7/6/26.
//

import SwiftUI

struct PrivacyPolicyScreen: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("Last Updated: July 2026")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // MARK: - Section 1
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Information We Collect")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("To provide our services, we collect your email address for account authentication. We also collect the personal and financial information you voluntarily input into our questionnaires. This may include income, expenses, and demographic data required to complete your tax forms.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Section 2
                    VStack(alignment: .leading, spacing: 8) {
                        Text("2. How We Use Your Data")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Your data is used strictly for core app functionality: maintaining your account and generating your PDF tax forms. We do not use your financial information for marketing, nor do we use it for targeted advertising.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Section 3
                    VStack(alignment: .leading, spacing: 8) {
                        Text("3. Data Sharing & Third Parties")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("We absolutely do not sell, rent, or trade your personal or financial data. We utilize trusted third-party cloud services (such as Google Firebase) solely to securely store and process your data. These providers are bound by strict confidentiality and security standards.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Section 4
                    VStack(alignment: .leading, spacing: 8) {
                        Text("4. Data Security")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("We implement industry-standard security measures, including data encryption in transit and at rest, to protect your sensitive information. However, no electronic transmission or storage system is 100% secure, and we cannot guarantee absolute security.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Section 5
                    VStack(alignment: .leading, spacing: 8) {
                        Text("5. Account Deletion")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("You have the right to request the deletion of your account and all associated tax data at any time. You can do this directly within the app settings or by contacting our support team.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // MARK: - Link to Terms of Service
                    NavigationLink(destination: TermsOfServiceScreen()) {
                        HStack {
                            Text("Read our Terms of Service")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: - Close Button
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicyScreen()
}
