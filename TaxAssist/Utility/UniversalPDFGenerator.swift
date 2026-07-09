//
//  UniversalPDFGenerator.swift
//  TaxAssist
//

import SwiftUI
import UIKit

// MARK: - Reusable UI Components
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

// MARK: - Generic PDF Error
enum PDFGenerationError: LocalizedError {
    case missingFormImage(String)

    var errorDescription: String? {
        switch self {
        case .missingFormImage(let imageName):
            return "The form image '\(imageName)' could not be found in assets."
        }
    }
}

// MARK: - The Universal Engine
enum UniversalPDFGenerator {
    private static let pageRect = CGRect(x: 0, y: 0, width: 792, height: 612) // Standard Landscape
    private static let pageMargin: CGFloat = 36
    private static let imageAspectRatio = 728.0 / 420.0

    /// Generates a PDF using ANY base image, and uses a closure to draw the specific text.
    static func generate(
        baseImageName: String,
        outputFileName: String,
        drawFields: (_ imageRect: CGRect) -> Void
    ) throws -> URL {
        
        // 1. Find the base image
        guard let formImage = UIImage(named: baseImageName) else {
            throw PDFGenerationError.missingFormImage(baseImageName)
        }

        // 2. Set up the file path
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(safeFileName(from: outputFileName))

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        // 3. Render the PDF
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: fileURL) { context in
            context.beginPage()

            // Fill background white
            UIColor.white.setFill()
            context.cgContext.fill(pageRect)

            // Draw the base form image
            let imageRect = fittedImageRect()
            formImage.draw(in: imageRect)
            
            // EXECUTE THE CUSTOM FORM DRAWING LOGIC
            drawFields(imageRect)
        }

        return fileURL
    }

    // MARK: - Helper Methods (Exposed for your forms to use)
    
    /// Converts relative coordinates (0.0 to 1.0) into exact PDF pixel coordinates
    static func fieldRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, inside imageRect: CGRect) -> CGRect {
        CGRect(
            x: imageRect.minX + x * imageRect.width,
            y: imageRect.minY + y * imageRect.height,
            width: width * imageRect.width,
            height: height * imageRect.height
        )
    }

    /// Safely draws text onto the PDF if the text exists
    static func drawText(_ text: String, in rect: CGRect, fontSize: CGFloat = 10) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]

        value.draw(in: rect, withAttributes: attributes)
    }

    // MARK: - Internal Engine Math
    
    private static func safeFileName(from requestedName: String) -> String {
        let safeName = requestedName.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
        return "\(safeName).pdf"
    }

    private static func fittedImageRect() -> CGRect {
        let availableRect = pageRect.insetBy(dx: pageMargin, dy: pageMargin)
        let availableRatio = availableRect.width / availableRect.height

        if availableRatio > imageAspectRatio {
            let width = availableRect.height * imageAspectRatio
            return CGRect(
                x: availableRect.midX - width / 2,
                y: availableRect.minY,
                width: width,
                height: availableRect.height
            )
        }

        let height = availableRect.width / imageAspectRatio
        return CGRect(
            x: availableRect.minX,
            y: availableRect.midY - height / 2,
            width: availableRect.width,
            height: height
        )
    }
}
