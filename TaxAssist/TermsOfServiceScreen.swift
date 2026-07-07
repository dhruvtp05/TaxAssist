//
//  TermsOfServiceScreen.swift
//  TaxAssist
//
//  Created by Dhruv Patel on 7/6/26.
//

import SwiftUI

struct TermsOfServiceScreen: View {
    // This allows us to easily close the screen when the user is done reading
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
                        Text("1. Acceptance of Terms")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("By creating an account or using Tax Assist, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Section 2
                    VStack(alignment: .leading, spacing: 8) {
                        Text("2. No Professional Tax Advice")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.red) // Highlighted for legal emphasis
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Tax Assist provides software tools to help format and generate PDF tax forms based solely on user inputs. Tax Assist is NOT a Certified Public Accountant (CPA), financial advisor, or tax attorney. We do not provide tax, legal, or financial advice. You are solely responsible for verifying the accuracy of your forms before filing them with the IRS or state tax authorities.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Section 3
                    VStack(alignment: .leading, spacing: 8) {
                        Text("3. User Responsibilities & Accuracy")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("The accuracy of the generated tax documents relies entirely on the information you provide. Tax Assist is not liable for any audits, penalties, fines, or delayed returns resulting from incorrect or incomplete information entered into the application.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Section 4
                    VStack(alignment: .leading, spacing: 8) {
                        Text("4. Account Security")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("You are responsible for maintaining the confidentiality of your login credentials. Tax Assist reserves the right to suspend or terminate accounts that engage in fraudulent activity or violate these terms.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Section 5
                    VStack(alignment: .leading, spacing: 8) {
                        Text("5. Limitation of Liability")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("To the maximum extent permitted by law, Tax Assist and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .lineSpacing(4)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // MARK: - Link to Privacy Policy
                    NavigationLink(destination: PrivacyPolicyScreen()) {
                        HStack {
                            Text("Read our Privacy Policy")
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
            .navigationTitle("Terms of Service")
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
    TermsOfServiceScreen()
}
