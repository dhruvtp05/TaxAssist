//
//  AccessibilitySettings.swift
//  TaxAssist
//
//  Created by SandboxLab on 7/16/26.
//

import SwiftUI

struct AccessibilitySettingsView: View {

    // Existing toggles that map well to the new UI
    @AppStorage("accessibilityBoldText") private var accessibilityBoldText: Bool = false
    @AppStorage("accessibilityReduceMotion") private var accessibilityReduceMotion: Bool = false

    // New state to match the exact controls in the screenshot
    // Text & Display
    @AppStorage("accessibilityTextSize") private var accessibilityTextSize: Double = 0.5 // 0.0 = Small, 1.0 = Large
    @AppStorage("accessibilityDisplayContrast") private var accessibilityDisplayContrast: Int = 1 // 0=L, 1=M, 2=H

    // Interaction
    @AppStorage("accessibilityLargerTouchTargets") private var accessibilityLargerTouchTargets: Int = 0 // 0=Small, 1=Large
    @AppStorage("accessibilityAssistiveTouch") private var accessibilityAssistiveTouch: Bool = false
    @AppStorage("accessibilityTimeoutDuration") private var accessibilityTimeoutDuration: Double = 60 // seconds

    @State private var isDraggingTimeout = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Text & Display
                Section {
                    // Text Size row
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "textformat.size.larger")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Text Size")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("Adjust the size of text throughout the app.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 6) {
                            Text("A")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.secondary)
                            Text("A")
                                .font(.system(size: 20 + CGFloat(accessibilityTextSize) * 10, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        .accessibilityHidden(true)
                    }
                    .accessibilityElement(children: .combine)

                    Slider(value: $accessibilityTextSize, in: 0.0...1.0, step: 0.05) {
                        Text("Text Size")
                    }
                    .accessibilityIdentifier("textSizeSlider")

                    // Display Contrast row (segmented L / M / H)
                    HStack(spacing: 12) {
                        Image(systemName: "circle.lefthalf.filled")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Display Contrast")
                                .font(.body)
                            Text("Increase contrast for better visibility.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Picker("Display Contrast", selection: $accessibilityDisplayContrast) {
                            Text("L").tag(0)
                            Text("M").tag(1)
                            Text("H").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 180)
                        .accessibilityIdentifier("displayContrastSegmented")
                    }

                    // Bold Text toggle
                    Toggle(isOn: $accessibilityBoldText) {
                        HStack(spacing: 12) {
                            Image(systemName: "bold")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            Text("Bold Text")
                        }
                    }
                    .accessibilityIdentifier("boldTextToggle")

                    // Reduce Motion toggle
                    Toggle(isOn: $accessibilityReduceMotion) {
                        HStack(spacing: 12) {
                            Image(systemName: "figure.walk.motion")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reduce Motion")
                                Text("Minimize animations and motion.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .accessibilityIdentifier("reduceMotionToggle")

                } header: {
                    Text("Text & Display")
                        .font(.subheadline).bold()
                }

                // MARK: Interaction
                Section {
                    // Larger Touch Targets (Small / Large)
                    HStack(spacing: 12) {
                        Image(systemName: "hand.tap")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Larger Touch Targets")
                            Text("Increase the size of buttons and controls.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Picker("Larger Touch Targets", selection: $accessibilityLargerTouchTargets) {
                            Text("Small").tag(0)
                            Text("Large").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 200)
                        .accessibilityIdentifier("largerTouchTargetsSegmented")
                    }

                    // Assistive Touch toggle
                    Toggle(isOn: $accessibilityAssistiveTouch) {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.point.up.left.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Assistive Touch")
                                Text("Show on-screen controls.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .accessibilityIdentifier("assistiveTouchToggle")

                    // Timeout Duration (slider + labeled endpoints)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "timer")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Timeout Duration")
                                Text("Adjust how long the app waits.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        HStack {
                            Text("15s")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Slider(value: $accessibilityTimeoutDuration, in: 15...120, step: 5) {
                                Text("Timeout Duration")
                            } minimumValueLabel: {
                                EmptyView()
                            } maximumValueLabel: {
                                EmptyView()
                            }
                            .accessibilityIdentifier("timeoutDurationSlider")
                            Text("120s")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Spacer()
                            Text("\(Int(accessibilityTimeoutDuration)) seconds")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                } header: {
                    Text("Interaction")
                        .font(.subheadline).bold()
                }

                // MARK: Support
                Section {
                    NavigationLink {
                        AccessibilityGuideView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "book.closed")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Accessibility Guide")
                                Text("Learn more about accessibility features.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .accessibilityIdentifier("accessibilityGuideLink")

                    NavigationLink {
                        AccessibilityReportIssueView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.bubble")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Report an Issue")
                                Text("Your accessibility preferences are saved automatically and can be changed at any time.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .accessibilityIdentifier("reportIssueLink")
                } header: {
                    Text("Support")
                        .font(.subheadline).bold()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Accessibility")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Simple placeholder views for the support links
private struct AccessibilityGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Accessibility Guide")
                    .font(.title2).bold()
                Text("This is a placeholder guide. Provide tips, explanations, and links to help users configure the app for their needs.")
            }
            .padding()
        }
        .navigationTitle("Accessibility Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AccessibilityReportIssueView: View {
    var body: some View {
        Form {
            Section("Describe the issue") {
                TextEditor(text: .constant(""))
                    .frame(minHeight: 160)
            }
        }
        .navigationTitle("Report an Issue")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AccessibilitySettingsView()
}

