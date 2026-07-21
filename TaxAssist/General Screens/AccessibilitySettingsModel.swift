import SwiftUI

final class AccessibilitySettings: ObservableObject {
    static let shared = AccessibilitySettings()

    @AppStorage("accessibilityLargerText") private var storedAccessibilityLargerText: Bool = false
    @AppStorage("accessibilityBoldText") private var storedAccessibilityBoldText: Bool = false
    @AppStorage("accessibilityReduceMotion") private var storedAccessibilityReduceMotion: Bool = false
    @AppStorage("accessibilityHighContrast") private var storedAccessibilityHighContrast: Bool = false
    @AppStorage("accessibilityButtonShapes") private var storedAccessibilityButtonShapes: Bool = false
    @AppStorage("accessibilityVoiceOverHints") private var storedAccessibilityVoiceOverHints: Bool = false
    @AppStorage("accessibilityNumericKeypad") private var storedAccessibilityNumericKeypad: Bool = false
    @AppStorage("accessibilitySimplifiedForms") private var storedAccessibilitySimplifiedForms: Bool = false
    @AppStorage("accessibilityReportSeparators") private var storedAccessibilityReportSeparators: Bool = false
    @AppStorage("accessibilityHighContrastCharts") private var storedAccessibilityHighContrastCharts: Bool = false
    @AppStorage("accessibilityCurrencySpacing") private var storedAccessibilityCurrencySpacing: Bool = false
    @AppStorage("accessibilityReadNumbersAsDigits") private var storedAccessibilityReadNumbersAsDigits: Bool = false
    @AppStorage("accessibilitySwipeToDelete") private var storedAccessibilitySwipeToDelete: Bool = false
    @AppStorage("accessibilityQuickSectionNavigation") private var storedAccessibilityQuickSectionNavigation: Bool = false
    @AppStorage("accessibilityConciseLabels") private var storedAccessibilityConciseLabels: Bool = false
    @AppStorage("accessibilityConfirmDestructive") private var storedAccessibilityConfirmDestructive: Bool = false
    @AppStorage("accessibilityTextSizeScalar") private var storedAccessibilityTextSizeScalar: Double = 1.0
    @AppStorage("accessibilityLargerTouchTargets") private var storedAccessibilityLargerTouchTargets: Bool = false
    @AppStorage("accessibilityAssistiveTouch") private var storedAccessibilityAssistiveTouch: Bool = false
    @AppStorage("accessibilityTimeoutDuration") private var storedAccessibilityTimeoutDuration: Double = 0.0
    @AppStorage("customBackgroundPreset") private var storedCustomBackgroundPreset: String = ""
    @AppStorage("customTextHue") private var storedCustomTextHue: Double = 0.0

    @Published var accessibilityLargerText: Bool {
        didSet { storedAccessibilityLargerText = accessibilityLargerText }
    }
    @Published var accessibilityBoldText: Bool {
        didSet { storedAccessibilityBoldText = accessibilityBoldText }
    }
    @Published var accessibilityReduceMotion: Bool {
        didSet { storedAccessibilityReduceMotion = accessibilityReduceMotion }
    }
    @Published var accessibilityHighContrast: Bool {
        didSet { storedAccessibilityHighContrast = accessibilityHighContrast }
    }
    @Published var accessibilityButtonShapes: Bool {
        didSet { storedAccessibilityButtonShapes = accessibilityButtonShapes }
    }
    @Published var accessibilityVoiceOverHints: Bool {
        didSet { storedAccessibilityVoiceOverHints = accessibilityVoiceOverHints }
    }
    @Published var accessibilityNumericKeypad: Bool {
        didSet { storedAccessibilityNumericKeypad = accessibilityNumericKeypad }
    }
    @Published var accessibilitySimplifiedForms: Bool {
        didSet { storedAccessibilitySimplifiedForms = accessibilitySimplifiedForms }
    }
    @Published var accessibilityReportSeparators: Bool {
        didSet { storedAccessibilityReportSeparators = accessibilityReportSeparators }
    }
    @Published var accessibilityHighContrastCharts: Bool {
        didSet { storedAccessibilityHighContrastCharts = accessibilityHighContrastCharts }
    }
    @Published var accessibilityCurrencySpacing: Bool {
        didSet { storedAccessibilityCurrencySpacing = accessibilityCurrencySpacing }
    }
    @Published var accessibilityReadNumbersAsDigits: Bool {
        didSet { storedAccessibilityReadNumbersAsDigits = accessibilityReadNumbersAsDigits }
    }
    @Published var accessibilitySwipeToDelete: Bool {
        didSet { storedAccessibilitySwipeToDelete = accessibilitySwipeToDelete }
    }
    @Published var accessibilityQuickSectionNavigation: Bool {
        didSet { storedAccessibilityQuickSectionNavigation = accessibilityQuickSectionNavigation }
    }
    @Published var accessibilityConciseLabels: Bool {
        didSet { storedAccessibilityConciseLabels = accessibilityConciseLabels }
    }
    @Published var accessibilityConfirmDestructive: Bool {
        didSet { storedAccessibilityConfirmDestructive = accessibilityConfirmDestructive }
    }
    @Published var accessibilityTextSizeScalar: Double {
        didSet { storedAccessibilityTextSizeScalar = accessibilityTextSizeScalar }
    }
    @Published var accessibilityLargerTouchTargets: Bool {
        didSet { storedAccessibilityLargerTouchTargets = accessibilityLargerTouchTargets }
    }
    @Published var accessibilityAssistiveTouch: Bool {
        didSet { storedAccessibilityAssistiveTouch = accessibilityAssistiveTouch }
    }
    @Published var accessibilityTimeoutDuration: Double {
        didSet { storedAccessibilityTimeoutDuration = accessibilityTimeoutDuration }
    }
    @Published var customBackgroundPreset: String {
        didSet { storedCustomBackgroundPreset = customBackgroundPreset }
    }
    @Published var customTextHue: Double {
        didSet { storedCustomTextHue = customTextHue }
    }

    init() {
        accessibilityLargerText = storedAccessibilityLargerText
        accessibilityBoldText = storedAccessibilityBoldText
        accessibilityReduceMotion = storedAccessibilityReduceMotion
        accessibilityHighContrast = storedAccessibilityHighContrast
        accessibilityButtonShapes = storedAccessibilityButtonShapes
        accessibilityVoiceOverHints = storedAccessibilityVoiceOverHints
        accessibilityNumericKeypad = storedAccessibilityNumericKeypad
        accessibilitySimplifiedForms = storedAccessibilitySimplifiedForms
        accessibilityReportSeparators = storedAccessibilityReportSeparators
        accessibilityHighContrastCharts = storedAccessibilityHighContrastCharts
        accessibilityCurrencySpacing = storedAccessibilityCurrencySpacing
        accessibilityReadNumbersAsDigits = storedAccessibilityReadNumbersAsDigits
        accessibilitySwipeToDelete = storedAccessibilitySwipeToDelete
        accessibilityQuickSectionNavigation = storedAccessibilityQuickSectionNavigation
        accessibilityConciseLabels = storedAccessibilityConciseLabels
        accessibilityConfirmDestructive = storedAccessibilityConfirmDestructive
        accessibilityTextSizeScalar = storedAccessibilityTextSizeScalar
        accessibilityLargerTouchTargets = storedAccessibilityLargerTouchTargets
        accessibilityAssistiveTouch = storedAccessibilityAssistiveTouch
        accessibilityTimeoutDuration = storedAccessibilityTimeoutDuration
        customBackgroundPreset = storedCustomBackgroundPreset
        customTextHue = storedCustomTextHue
    }

    func reset() {
        accessibilityLargerText = false
        accessibilityBoldText = false
        accessibilityReduceMotion = false
        accessibilityHighContrast = false
        accessibilityButtonShapes = false
        accessibilityVoiceOverHints = false
        accessibilityNumericKeypad = false
        accessibilitySimplifiedForms = false
        accessibilityReportSeparators = false
        accessibilityHighContrastCharts = false
        accessibilityCurrencySpacing = false
        accessibilityReadNumbersAsDigits = false
        accessibilitySwipeToDelete = false
        accessibilityQuickSectionNavigation = false
        accessibilityConciseLabels = false
        accessibilityConfirmDestructive = false
        accessibilityTextSizeScalar = 1.0
        accessibilityLargerTouchTargets = false
        accessibilityAssistiveTouch = false
        accessibilityTimeoutDuration = 0.0
        customBackgroundPreset = ""
        customTextHue = 0.0
    }
}
