import SwiftUI
import Combine

final class AccessibilitySettings: ObservableObject {
    
    static let shared = AccessibilitySettings()
    
    private let textSizeMin: Double = 0.8
    private let textSizeMax: Double = 1.6
    private let textSizeStep: Double = 0.05

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

    @Published var accessibilityLargerText: Bool = false {
        didSet { storedAccessibilityLargerText = accessibilityLargerText }
    }
    @Published var accessibilityBoldText: Bool = false {
        didSet { storedAccessibilityBoldText = accessibilityBoldText }
    }
    @Published var accessibilityReduceMotion: Bool = false {
        didSet { storedAccessibilityReduceMotion = accessibilityReduceMotion }
    }
    @Published var accessibilityHighContrast: Bool = false {
        didSet { storedAccessibilityHighContrast = accessibilityHighContrast }
    }
    @Published var accessibilityButtonShapes: Bool = false {
        didSet { storedAccessibilityButtonShapes = accessibilityButtonShapes }
    }
    @Published var accessibilityVoiceOverHints: Bool = false {
        didSet { storedAccessibilityVoiceOverHints = accessibilityVoiceOverHints }
    }
    @Published var accessibilityNumericKeypad: Bool = false {
        didSet { storedAccessibilityNumericKeypad = accessibilityNumericKeypad }
    }
    @Published var accessibilitySimplifiedForms: Bool = false {
        didSet { storedAccessibilitySimplifiedForms = accessibilitySimplifiedForms }
    }
    @Published var accessibilityReportSeparators: Bool = false {
        didSet { storedAccessibilityReportSeparators = accessibilityReportSeparators }
    }
    @Published var accessibilityHighContrastCharts: Bool = false {
        didSet { storedAccessibilityHighContrastCharts = accessibilityHighContrastCharts }
    }
    @Published var accessibilityCurrencySpacing: Bool = false {
        didSet { storedAccessibilityCurrencySpacing = accessibilityCurrencySpacing }
    }
    @Published var accessibilityReadNumbersAsDigits: Bool = false {
        didSet { storedAccessibilityReadNumbersAsDigits = accessibilityReadNumbersAsDigits }
    }
    @Published var accessibilitySwipeToDelete: Bool = false {
        didSet { storedAccessibilitySwipeToDelete = accessibilitySwipeToDelete }
    }
    @Published var accessibilityQuickSectionNavigation: Bool = false {
        didSet { storedAccessibilityQuickSectionNavigation = accessibilityQuickSectionNavigation }
    }
    @Published var accessibilityConciseLabels: Bool = false {
        didSet { storedAccessibilityConciseLabels = accessibilityConciseLabels }
    }
    @Published var accessibilityConfirmDestructive: Bool = false {
        didSet { storedAccessibilityConfirmDestructive = accessibilityConfirmDestructive }
    }
    @Published var accessibilityTextSizeScalar: Double = 1.0 {
        didSet {
            // Clamp and persist
            if accessibilityTextSizeScalar < textSizeMin { accessibilityTextSizeScalar = textSizeMin }
            if accessibilityTextSizeScalar > textSizeMax { accessibilityTextSizeScalar = textSizeMax }
            storedAccessibilityTextSizeScalar = accessibilityTextSizeScalar
        }
    }
    @Published var accessibilityLargerTouchTargets: Bool = false {
        didSet { storedAccessibilityLargerTouchTargets = accessibilityLargerTouchTargets }
    }
    @Published var accessibilityAssistiveTouch: Bool = false {
        didSet { storedAccessibilityAssistiveTouch = accessibilityAssistiveTouch }
    }
    @Published var accessibilityTimeoutDuration: Double = 0.0 {
        didSet { storedAccessibilityTimeoutDuration = accessibilityTimeoutDuration }
    }
    @Published var customBackgroundPreset: String = "" {
        didSet { storedCustomBackgroundPreset = customBackgroundPreset }
    }
    @Published var customTextHue: Double = 0.0 {
        didSet { storedCustomTextHue = customTextHue }
    }

    init() {
        // Read from @AppStorage into local temps to avoid using self before initialization completes
        let largerText = storedAccessibilityLargerText
        let boldText = storedAccessibilityBoldText
        let reduceMotion = storedAccessibilityReduceMotion
        let highContrast = storedAccessibilityHighContrast
        let buttonShapes = storedAccessibilityButtonShapes
        let voiceOverHints = storedAccessibilityVoiceOverHints
        let numericKeypad = storedAccessibilityNumericKeypad
        let simplifiedForms = storedAccessibilitySimplifiedForms
        let reportSeparators = storedAccessibilityReportSeparators
        let highContrastCharts = storedAccessibilityHighContrastCharts
        let currencySpacing = storedAccessibilityCurrencySpacing
        let readNumbersAsDigits = storedAccessibilityReadNumbersAsDigits
        let swipeToDelete = storedAccessibilitySwipeToDelete
        let quickSectionNavigation = storedAccessibilityQuickSectionNavigation
        let conciseLabels = storedAccessibilityConciseLabels
        let confirmDestructive = storedAccessibilityConfirmDestructive
        let textSizeScalar = storedAccessibilityTextSizeScalar
        let largerTouchTargets = storedAccessibilityLargerTouchTargets
        let assistiveTouch = storedAccessibilityAssistiveTouch
        let timeoutDuration = storedAccessibilityTimeoutDuration
        let backgroundPreset = storedCustomBackgroundPreset
        let textHue = storedCustomTextHue

        // Now assign to published properties
        self.accessibilityLargerText = largerText
        self.accessibilityBoldText = boldText
        self.accessibilityReduceMotion = reduceMotion
        self.accessibilityHighContrast = highContrast
        self.accessibilityButtonShapes = buttonShapes
        self.accessibilityVoiceOverHints = voiceOverHints
        self.accessibilityNumericKeypad = numericKeypad
        self.accessibilitySimplifiedForms = simplifiedForms
        self.accessibilityReportSeparators = reportSeparators
        self.accessibilityHighContrastCharts = highContrastCharts
        self.accessibilityCurrencySpacing = currencySpacing
        self.accessibilityReadNumbersAsDigits = readNumbersAsDigits
        self.accessibilitySwipeToDelete = swipeToDelete
        self.accessibilityQuickSectionNavigation = quickSectionNavigation
        self.accessibilityConciseLabels = conciseLabels
        self.accessibilityConfirmDestructive = confirmDestructive
        self.accessibilityTextSizeScalar = textSizeScalar
        if self.accessibilityTextSizeScalar < textSizeMin { self.accessibilityTextSizeScalar = textSizeMin }
        if self.accessibilityTextSizeScalar > textSizeMax { self.accessibilityTextSizeScalar = textSizeMax }
        self.accessibilityLargerTouchTargets = largerTouchTargets
        self.accessibilityAssistiveTouch = assistiveTouch
        self.accessibilityTimeoutDuration = timeoutDuration
        self.customBackgroundPreset = backgroundPreset
        self.customTextHue = textHue
    }

    // MARK: - Text Size Adjuster Helpers
    func increaseTextSize() {
        accessibilityTextSizeScalar = min(accessibilityTextSizeScalar + textSizeStep, textSizeMax)
    }

    func decreaseTextSize() {
        accessibilityTextSizeScalar = max(accessibilityTextSizeScalar - textSizeStep, textSizeMin)
    }

    func resetTextSize() {
        accessibilityTextSizeScalar = 1.0
    }

    var textSizeDisplayLabel: String {
        String(format: "%.0f%%", accessibilityTextSizeScalar * 100)
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
