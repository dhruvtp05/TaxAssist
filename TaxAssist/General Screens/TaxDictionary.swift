//
//  TaxDictionary.swift
//  TaxAssist
//
//  Created by SandboxLab on 7/13/26.
//
//  This screen just displays whatever is in `taxTerms`
//  (see TaxTermsData.swift). Add/edit terms there — nothing
//  here needs to change.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// Represents either a letter header or a term row in the flattened list.
private enum DictionaryRow: Identifiable {
    case header(String)
    case term(TaxTerm)

    var id: String {
        switch self {
        case .header(let letter): return "header-\(letter)"
        case .term(let term): return term.id.uuidString
        }
    }
}

struct TaxDictionary: View {
    @AppStorage("customBackgroundPreset") private var customBackgroundPreset: String = "white"
    @AppStorage("customTextHue") private var customTextHue: Double = 0.58
    @AppStorage("accessibilityLargerText") private var accessibilityLargerText: Bool = false
    @AppStorage("accessibilityBoldText") private var accessibilityBoldText: Bool = false
    @AppStorage("accessibilityReduceMotion") private var accessibilityReduceMotion: Bool = false
    @AppStorage("accessibilityConciseLabels") private var accessibilityConciseLabels: Bool = true

    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""

    private var filteredTerms: [TaxTerm] {
        guard !searchText.isEmpty else { return taxTerms }
        return taxTerms.filter {
            $0.term.localizedCaseInsensitiveContains(searchText) ||
            $0.definition.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Groups filtered terms alphabetically by first letter, in sorted section order.
    private var groupedTerms: [(letter: String, terms: [TaxTerm])] {
        let grouped = Dictionary(grouping: filteredTerms) { term -> String in
            String(term.term.first ?? " ").uppercased()
        }
        return grouped
            .sorted { $0.key < $1.key }
            .map { (letter: $0.key, terms: $0.value.sorted { $0.term < $1.term }) }
    }

    // Flattens the grouped sections into a single row list (headers + terms mixed).
    // This lets us control spacing directly per-row instead of relying on List's
    // built-in Section spacing, which was causing the uneven gaps between letters.
    private var flattenedRows: [DictionaryRow] {
        var rows: [DictionaryRow] = []
        for section in groupedTerms {
            rows.append(.header(section.letter))
            rows.append(contentsOf: section.terms.map { .term($0) })
        }
        return rows
    }

    private var customBackgroundColor: Color {
        switch customBackgroundPreset {
        case "blue": return Color.blue.opacity(0.15)
        case "black": return Color.black.opacity(0.9)
        case "sky": return Color(red: 0.75, green: 0.88, blue: 1.0)
        default: return .white
        }
    }
    private var contrastingForegroundColor: Color {
        #if canImport(UIKit)
        let ui = UIColor(customBackgroundColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
            return luminance < 0.5 ? .white : .black
        } else {
            var white: CGFloat = 0
            ui.getWhite(&white, alpha: nil)
            return white < 0.5 ? .white : .black
        }
        #else
        return .primary
        #endif
    }
    private var customTextColor: Color {
        #if canImport(UIKit)
        let base = Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
        let fg = UIColor(contrastingForegroundColor)
        let bs = UIColor(base)
        var fr: CGFloat = 0, fgG: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        bs.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        fg.getRed(&fr, green: &fgG, blue: &fb, alpha: &fa)
        let mix: (CGFloat, CGFloat) -> CGFloat = { (u, c) in min(max(u * 0.75 + c * 0.25, 0), 1) }
        let rr = mix(br, fr), gg = mix(bg, fgG), bb2 = mix(bb, fb)
        return Color(red: rr, green: gg, blue: bb2)
        #else
        return Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
        #endif
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredTerms.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(flattenedRows) { row in
                            switch row {
                            case .header(let letter):
                                Text(letter)
                                    .font(.footnote.bold())
                                    .foregroundColor(customTextColor)
                                    .listRowInsets(EdgeInsets(top: 14, leading: 16, bottom: 2, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            case .term(let term):
                                TermRow(term: term, accent: customTextColor)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .dynamicTypeSize(accessibilityLargerText ? .accessibility3 : .large)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search tax terms")
            .navigationTitle(accessibilityConciseLabels ? "Dictionary" : "Tax Dictionary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(customTextColor, lineWidth: 2)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(customTextColor)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
            .toolbarBackground(customBackgroundColor, for: .navigationBar)
            .toolbarColorScheme(contrastingForegroundColor == .white ? .dark : .light, for: .navigationBar)
            .background(customBackgroundColor.ignoresSafeArea())
            .transaction { tx in if accessibilityReduceMotion { tx.animation = nil } }
        }
    }

    // MARK: Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 34))
                .foregroundColor(Color(uiColor: .systemGray3))
            Text("No terms found")
                .font(.headline)
            Text("Try searching a different word.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(customBackgroundColor.ignoresSafeArea())
    }
}

// MARK: - Term Row

private struct TermRow: View {
    let term: TaxTerm
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 13))
                        .foregroundColor(accent)
                }
                Text(term.term)
                    .font(.headline)
                    .foregroundColor(accent)
            }

            Text(term.definition)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(3)
                .padding(.leading, 38)
        }
    }
}

// MARK: - Preview

#Preview {
    TaxDictionary()
}
