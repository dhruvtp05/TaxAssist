//
//  LoadingScreenTwo.swift
//  TaxAssist
//
//  Created by Dhruv Patel on 7/6/26.
//

import SwiftUI

struct LoadingScreenTwo: View {
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            // A semi-transparent background to blur/dim the screen behind it
            Color.white.opacity(0.9)
                .ignoresSafeArea()
            
            // MARK: - The Infinite Spinner
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color(UIColor.systemGray5), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                // Spinning Indicator
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                isRotating = true
            }
        }
    }
}

#Preview {
    // Wrapping it in a mock background so you can see the transparency effect in the preview. NEED TO MAKE SURE THAT THE LOADING SCREEN IS IN FRONT OF LOADING CONTENT
    
    ZStack {
        Color.blue.opacity(0.2).ignoresSafeArea()
        Text("Behind the scenes content...")
        
        LoadingScreenTwo()
    }
}
