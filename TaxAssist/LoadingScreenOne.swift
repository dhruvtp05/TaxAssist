//
//  LoadingScreenOne.swift
//  TaxAssist
//
//  Created by Dhruv Patel on 7/2/26.
//

import SwiftUI

struct LoadingScreenOne: View {
    @State private var isRotating = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // MARK: - Logo & Brand Name
            HStack(spacing: 16) {
                
                // Icon Approximation
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue, lineWidth: 5)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                // Title Text
                HStack(spacing: 0) {
                    Text("Tax")
                        .foregroundColor(.black)
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
                
                // Spinning Indicator
                Circle()
                    // Leave a permanent gap so you can actually see it spinning
                    .trim(from: 0.0, to: 0.75)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    // The rotation animation target
                    .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        
        // Trigger the infinite animation as soon as the screen loads
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
