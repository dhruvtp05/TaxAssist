//
//  AccessibilitySettings.swift
//  TaxAssist
//
//  Created by SandboxLab on 7/16/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
struct AccessibilitySettingsView: View {
    
    @AppStorage("accessibilityLargerText") private var accessibilityLargerText: Bool = false
    @AppStorage("accessibilityBoldText") private var accessibilityBoldText: Bool = false
    @AppStorage("accessibilityReduceMotion") private var accessibilityReduceMotion: Bool = false
    @AppStorage("accessibilityHighContrast") private var accessibilityHighContrast: Bool = false
    @AppStorage("accessibilityButtonShapes") private var accessibilityButtonShapes: Bool = false
    @AppStorage("accessibilityVoiceOverHints") private var accessibilityVoiceOverHints: Bool = true
    
    @AppStorage("accessibilityNumericKeypad") private var accessibilityNumericKeypad: Bool = true
    @AppStorage("accessibilitySimplifiedForms") private var accessibilitySimplifiedForms: Bool = false
    @AppStorage("accessibilityReportSeparators") private var accessibilityReportSeparators: Bool = true
    @AppStorage("accessibilityHighContrastCharts") private var accessibilityHighContrastCharts: Bool = false
    @AppStorage("accessibilityCurrencySpacing") private var accessibilityCurrencySpacing: Bool = true
    @AppStorage("accessibilityReadNumbersAsDigits") private var accessibilityReadNumbersAsDigits: Bool = false
    
    @AppStorage("customBackgroundPreset") private var customBackgroundPreset: String = "white"
    @AppStorage("customTextHue") private var customTextHue: Double = 0.58

    @State private var motionAnimationActive = false
    
    private var customBackgroundColor: Color {
        switch customBackgroundPreset {
        case "white":
            return Color.white
        case "blue":
            return Color.blue
        case "black":
            return Color.black.opacity(0.9)
        case "sky":
            return Color("sky")
        default:
            return Color.white
        }
    }
    
    private var contrastingForegroundColor: Color {
        // Calculate luminance and choose white or black accordingly
        // Use sRGB components for calculation
        #if canImport(UIKit)
        let uiColor = UIColor(customBackgroundColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #else
        let red = 1.0
        let green = 1.0
        let blue = 1.0
        #endif
        
        func adjust(_ c: CGFloat) -> CGFloat {
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055)/1.055, 2.4)
        }
        
        let r = adjust(red)
        let g = adjust(green)
        let b = adjust(blue)
        
        // Relative luminance formula
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        
        return luminance < 0.5 ? Color.white : Color.black
    }

    private var customTextColor: Color {
        // Use hue from storage and blend with contrastingForegroundColor on iOS
        #if canImport(UIKit)
        let baseColor = Color(hue: customTextHue, saturation: 0.8, brightness: 0.65)
        return baseColor.opacity(1.0).blend(with: contrastingForegroundColor, amount: 0.25)
        #else
        return Color(hue: customTextHue, saturation: 0.8, brightness: 0.65)
        #endif
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Larger text", isOn: $accessibilityLargerText)
                        .accessibilityIdentifier("largerTextToggle")
                        .fontWeight(accessibilityBoldText ? .bold : .regular)
                        .tint(customTextColor)
                        .dynamicTypeSize(accessibilityLargerText ? .accessibility3 : .large)
                        .listRowBackground(customBackgroundColor)
                        .accessibilityHint("Increases the base text size in supported areas of the app.")
                    
                    Toggle("Bold text", isOn: $accessibilityBoldText)
                        .accessibilityIdentifier("boldTextToggle")
                        .tint(customTextColor)
                        .listRowBackground(customBackgroundColor)
                    
                    Toggle("High contrast", isOn: $accessibilityHighContrast)
                        .accessibilityIdentifier("highContrastToggle")
                        .tint(customTextColor)
                        .listRowBackground(customBackgroundColor)
                    
                    VStack(spacing: 6) {
                        Text("Preview")
                            .font(.headline)
                            .foregroundColor(customTextColor)
                            .bold()
                        
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(customBackgroundColor)
                            .shadow(radius: accessibilityHighContrast ? 8 : 3)
                            .overlay(
                                Text("The quick brown fox jumps over the lazy dog")
                                    .font(accessibilityLargerText ? .title2 : .body)
                                    .fontWeight(accessibilityBoldText ? .bold : .regular)
                                    .foregroundColor(customTextColor)
                                    .padding()
                                    .multilineTextAlignment(.center)
                            )
                            .frame(height: 100)
                    }
                    .listRowBackground(customBackgroundColor)
                } header: {
                    HStack {
                        Image(systemName: "figure.accessibility")
                        Text("Vision & Display")
                    }
                    .foregroundStyle(customTextColor)
                }
                
                Section {
                    Toggle("Reduce motion", isOn: $accessibilityReduceMotion)
                        .accessibilityIdentifier("reduceMotionToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Limits animations and parallax effects to reduce motion.")
                        .listRowBackground(customBackgroundColor)
                    
                    HStack {
                        Spacer()
                        Circle()
                            .fill(customTextColor.opacity(0.7))
                            .frame(width: 50, height: 50)
                            .scaleEffect(motionAnimationActive ? 1.5 : 1)
                            .animation(accessibilityReduceMotion ? nil : .easeInOut(duration: 0.8), value: motionAnimationActive)
                        Spacer()
                    }
                    .listRowBackground(customBackgroundColor)
                    
                    Button {
                        motionAnimationActive.toggle()
                    } label: {
                        Text("Animate Circle")
                            .foregroundColor(customTextColor)
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(customBackgroundColor)
                } header: {
                    HStack {
                        Image(systemName: "figure.walk")
                        Text("Motion")
                    }
                    .foregroundStyle(customTextColor)
                }
                
                Section {
                    Toggle("Button shapes", isOn: $accessibilityButtonShapes)
                        .accessibilityIdentifier("buttonShapesToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Adds outlines or backgrounds to tappable elements for clarity.")
                        .listRowBackground(customBackgroundColor)
                    
                    Toggle("VoiceOver hints", isOn: $accessibilityVoiceOverHints)
                        .accessibilityIdentifier("voiceOverHintsToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Includes additional guidance for screen reader users.")
                        .listRowBackground(customBackgroundColor)
                    
                } header: {
                    HStack {
                        Image(systemName: "rectangle.and.hand.point.up.left")
                        Text("Controls")
                    }
                    .foregroundStyle(customTextColor)
                }
                
                Section {
                    Toggle("Prefer numeric keypad", isOn: $accessibilityNumericKeypad)
                        .accessibilityIdentifier("numericKeypadToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Shows a numeric keypad for amounts and percentages where possible.")
                        .listRowBackground(customBackgroundColor)
                    VStack(spacing: 8) {
                        Text("Shows a numeric keypad for amounts and percentages where possible.")
                            .font(.footnote)
                            .foregroundColor(customTextColor.opacity(0.7))
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text("Amount:")
                                .foregroundColor(customTextColor)
                            Spacer()
                            Image(systemName: "rectangle.grid.3x2")
                                .foregroundColor(customTextColor)
                                .font(.title2)
                        }
                    }
                    .listRowBackground(customBackgroundColor)
                    
                    Toggle("Simplified forms", isOn: $accessibilitySimplifiedForms)
                        .accessibilityIdentifier("simplifiedFormsToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Reduces optional fields and groups inputs to streamline entry.")
                        .listRowBackground(customBackgroundColor)
                    Text("Reduces optional fields and groups inputs to streamline entry.")
                        .font(.footnote)
                        .foregroundColor(customTextColor.opacity(0.7))
                        .listRowBackground(customBackgroundColor)
                    
                    Toggle("Currency symbol spacing", isOn: $accessibilityCurrencySpacing)
                        .accessibilityIdentifier("currencySpacingToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Adds a thin space between the currency symbol and amount for readability (e.g., $ 1,234.56).")
                        .listRowBackground(customBackgroundColor)
                    Text("Adds a thin space between the currency symbol and amount for readability (e.g., $ 1,234.56).")
                        .font(.footnote)
                        .foregroundColor(customTextColor.opacity(0.7))
                        .listRowBackground(customBackgroundColor)
                } header: {
                    HStack {
                        Image(systemName: "creditcard")
                        Text("Data Entry")
                    }
                    .foregroundStyle(customTextColor)
                }
                
                Section {
                    Toggle("Row separators in reports", isOn: $accessibilityReportSeparators)
                        .accessibilityIdentifier("reportSeparatorsToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Adds visible separators between rows in tables and reports.")
                        .listRowBackground(customBackgroundColor)
                    
                    if accessibilityReportSeparators {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Item")
                                    .fontWeight(.semibold)
                                    .foregroundColor(customTextColor)
                                Spacer()
                                Text("Amount")
                                    .fontWeight(.semibold)
                                    .foregroundColor(customTextColor)
                            }
                            .padding(.vertical, 4)
                            Divider()
                                .background(customTextColor.opacity(0.5))
                            HStack {
                                Text("Office Supplies")
                                    .foregroundColor(customTextColor)
                                Spacer()
                                Text("$123.45")
                                    .foregroundColor(customTextColor)
                            }
                            .padding(.vertical, 4)
                            Divider()
                                .background(customTextColor.opacity(0.5))
                            HStack {
                                Text("Travel")
                                    .foregroundColor(customTextColor)
                                Spacer()
                                Text("$987.65")
                                    .foregroundColor(customTextColor)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(customBackgroundColor)
                    }
                    
                    Toggle("High-contrast charts", isOn: $accessibilityHighContrastCharts)
                        .accessibilityIdentifier("highContrastChartsToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Uses stronger colors and outlines for chart elements.")
                        .listRowBackground(customBackgroundColor)
                    
                    if accessibilityHighContrastCharts {
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(customTextColor)
                                .frame(width: 40, height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(customTextColor, lineWidth: 2)
                                )
                            RoundedRectangle(cornerRadius: 4)
                                .fill(customTextColor.opacity(0.7))
                                .frame(width: 40, height: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(customTextColor, lineWidth: 2)
                                )
                            RoundedRectangle(cornerRadius: 4)
                                .fill(customTextColor.opacity(0.5))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(customTextColor, lineWidth: 2)
                                )
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(customBackgroundColor)
                    }
                    
                    Toggle("Read numbers as digits", isOn: $accessibilityReadNumbersAsDigits)
                        .accessibilityIdentifier("readNumbersDigitsToggle")
                        .tint(customTextColor)
                        .accessibilityHint("Screen readers will read numbers digit by digit (e.g., one-two-three) where supported.")
                        .listRowBackground(customBackgroundColor)
                    
                    Text("Screen readers will read numbers digit by digit (e.g., one-two-three) where supported.")
                        .font(.footnote)
                        .foregroundColor(customTextColor.opacity(0.7))
                        .listRowBackground(customBackgroundColor)
                } header: {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Reports & Reading")
                    }
                    .foregroundStyle(customTextColor)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(customBackgroundColor.ignoresSafeArea())
            .toolbarBackground(customBackgroundColor, for: .navigationBar)
            .toolbarColorScheme(contrastingForegroundColor == .white ? .dark : .light, for: .navigationBar)
            .navigationTitle("Accessibility")
            .navigationBarTitleDisplayMode(.inline)
            .tint(customTextColor)
        }
    }
}

#if canImport(UIKit)
private extension Color {
    /// Blend this color with another color by the given amount (0-1).
    func blend(with color: Color, amount: CGFloat) -> Color {
        let uiSelf = UIColor(self)
        let uiOther = UIColor(color)
        
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        uiSelf.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        uiOther.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let r = r1 * (1 - amount) + r2 * amount
        let g = g1 * (1 - amount) + g2 * amount
        let b = b1 * (1 - amount) + b2 * amount
        let a = a1 * (1 - amount) + a2 * amount
        
        return Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
}
#endif

#Preview {
    AccessibilitySettingsView()
}

