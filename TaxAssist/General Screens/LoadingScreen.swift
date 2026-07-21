//
//  LoadingScreenOne.swift
//  TaxAssist
//

import SwiftUI

struct LoadingScreenOne: View {
    @AppStorage("customBackgroundPreset") private var customBackgroundPreset: String = "white"
    @AppStorage("customTextHue") private var customTextHue: Double = 0.58
    
    @State private var isRotating = false
    
    private var customBackgroundColor: Color {
        switch customBackgroundPreset {
        case "blue": return Color.blue.opacity(0.15)
        case "black": return Color(red: 0.10, green: 0.11, blue: 0.12)
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
    private var accentColor: Color {
        #if canImport(UIKit)
        let base = Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
        let uiFG = UIColor(contrastingForegroundColor)
        let uiBase = UIColor(base)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        uiBase.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiFG.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let mix: (CGFloat, CGFloat) -> CGFloat = { (u, c) in min(max(u * 0.75 + c * 0.25, 0), 1) }
        return Color(red: Double(mix(r1, r2)), green: Double(mix(g1, g2)), blue: Double(mix(b1, b2)))
        #else
        return Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
        #endif
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // MARK: - Logo & Brand Name
            HStack(spacing: 16) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue, lineWidth: 5)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 0) {
                    Text("Tax")
                        .foregroundColor(contrastingForegroundColor == .white ? .white : .black)
                    Text("Assist")
                        .foregroundColor(.blue)
                }
                .font(.system(size: 44, weight: .bold))
            }
            .padding(.bottom, 60)
            
            // MARK: - Infinite Spinner
            ZStack {
                Circle()
                    .stroke(Color(UIColor.systemGray5), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(customBackgroundColor)
        
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                isRotating = true
            }
        }
    }
}

#Preview {
    LoadingScreenOne()
}
