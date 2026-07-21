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

    @AppStorage("accessibilitySwipeToDelete") private var accessibilitySwipeToDelete: Bool = true
    @AppStorage("accessibilityQuickSectionNavigation") private var accessibilityQuickSectionNavigation: Bool = true
    @AppStorage("accessibilityConciseLabels") private var accessibilityConciseLabels: Bool = true
    @AppStorage("accessibilityConfirmDestructive") private var accessibilityConfirmDestructive: Bool = true
    
    @AppStorage("customBackgroundPreset") private var customBackgroundPreset: String = "white"
    @AppStorage("customTextHue") private var customTextHue: Double = 0.58

    @State private var motionAnimationActive = false
    @State private var showingDestructiveExample = false
    
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
                    Toggle(isOn: $accessibilityLargerText) {
                        Text("Larger text").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("largerTextToggle")
                    .fontWeight(accessibilityBoldText ? .bold : .regular)
                    .listRowBackground(customBackgroundColor)
                    .accessibilityHint("Increases the base text size in supported areas of the app.")
                    
                    Toggle(isOn: $accessibilityBoldText) {
                        Text("Bold text").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("boldTextToggle")
                    .listRowBackground(customBackgroundColor)
                    
                    Toggle(isOn: $accessibilityHighContrast) {
                        Text("High contrast").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("highContrastToggle")
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
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                }
                .textCase(nil)
                
                Section {
                    Toggle(isOn: $accessibilityReduceMotion) {
                        Text("Reduce motion").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("reduceMotionToggle")
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
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                }
                .textCase(nil)
                
                Section {
                    Toggle(isOn: $accessibilityButtonShapes) {
                        Text("Button shapes").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("buttonShapesToggle")
                    .accessibilityHint("Adds outlines or backgrounds to tappable elements for clarity.")
                    .listRowBackground(customBackgroundColor)
                    
                    Toggle(isOn: $accessibilityVoiceOverHints) {
                        Text("VoiceOver hints").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("voiceOverHintsToggle")
                    .accessibilityHint("Includes additional guidance for screen reader users.")
                    .listRowBackground(customBackgroundColor)
                    
                } header: {
                    HStack {
                        Image(systemName: "rectangle.and.hand.point.up.left")
                        Text("Controls")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                }
                .textCase(nil)
                
                Section {
                    Toggle(isOn: $accessibilityNumericKeypad) {
                        Text("Prefer numeric keypad").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("numericKeypadToggle")
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
                    
                    Toggle(isOn: $accessibilitySimplifiedForms) {
                        Text("Simplified forms").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("simplifiedFormsToggle")
                    .accessibilityHint("Reduces optional fields and groups inputs to streamline entry.")
                    .listRowBackground(customBackgroundColor)
                    Text("Reduces optional fields and groups inputs to streamline entry.")
                        .font(.footnote)
                        .foregroundColor(customTextColor.opacity(0.7))
                        .listRowBackground(customBackgroundColor)
                    
                    Toggle(isOn: $accessibilityCurrencySpacing) {
                        Text("Currency symbol spacing").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("currencySpacingToggle")
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
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                }
                .textCase(nil)
                
                Section {
                    Toggle(isOn: $accessibilityReportSeparators) {
                        Text("Row separators in reports").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("reportSeparatorsToggle")
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
                    
                    Toggle(isOn: $accessibilityHighContrastCharts) {
                        Text("High-contrast charts").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("highContrastChartsToggle")
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
                    
                    Toggle(isOn: $accessibilityReadNumbersAsDigits) {
                        Text("Read numbers as digits").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("readNumbersDigitsToggle")
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
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                }
                .textCase(nil)
                
                Section {
                    Toggle(isOn: $accessibilitySwipeToDelete) {
                        Text("Swipe to delete").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("swipeToDeleteToggle")
                    .listRowBackground(customBackgroundColor)
                    Text("Allows removing items with a swipe gesture in lists (e.g., deleting a dependent).")
                        .font(.footnote)
                        .foregroundColor(customTextColor.opacity(0.7))
                        .listRowBackground(customBackgroundColor)
                    
                    Toggle(isOn: $accessibilityQuickSectionNavigation) {
                        Text("Quick section navigation").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("quickSectionNavToggle")
                    .accessibilityHint("Enables jump controls to move between tax sections quickly.")
                    .listRowBackground(customBackgroundColor)
                    HStack(spacing: 12) {
                        Image(systemName: "chevron.left.circle")
                            .foregroundColor(customTextColor)
                            .font(.title3)
                        Image(systemName: "chevron.right.circle")
                            .foregroundColor(customTextColor)
                            .font(.title3)
                    }
                    .listRowBackground(customBackgroundColor)
                    
                    Toggle(isOn: $accessibilityConciseLabels) {
                        Text("Concise labels").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("conciseLabelsToggle")
                    .accessibilityHint("Uses shorter labels and abbreviations where clear to reduce clutter.")
                    .listRowBackground(customBackgroundColor)
                    VStack(spacing: 4) {
                        HStack {
                            Text("Long Label Example")
                                .foregroundColor(customTextColor)
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "arrow.right")
                                .foregroundColor(customTextColor.opacity(0.7))
                            Spacer()
                        }
                        HStack {
                            Text("Concise Label")
                                .foregroundColor(customTextColor)
                            Spacer()
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(customTextColor.opacity(0.7))
                    .listRowBackground(customBackgroundColor)
                    
                    Toggle(isOn: $accessibilityConfirmDestructive) {
                        Text("Confirm destructive actions").foregroundColor(customTextColor)
                    }
                    .accessibilityIdentifier("confirmDestructiveToggle")
                    .accessibilityHint("Shows a confirmation before deleting or resetting data.")
                    .listRowBackground(customBackgroundColor)
                    
                    Button {
                        if accessibilityConfirmDestructive {
                            showingDestructiveExample = true
                        } else {
                            #if DEBUG
                            print("Delete action performed without confirmation")
                            #endif
                        }
                    } label: {
                        Label("Delete dependent…", systemImage: "trash")
                            .foregroundColor(customTextColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowBackground(customBackgroundColor)
                    .confirmationDialog("Delete this dependent?", isPresented: $showingDestructiveExample, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {}
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This action cannot be undone.")
                    }
                } header: {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Lists & Navigation")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(customTextColor)
                }
                .textCase(nil)
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

