//
//  W2PDF.swift
//  TaxAssist
//
//  Created by SandboxLab on 7/7/26.
//

import SwiftUI
import UIKit

struct GeneratedW2PDF: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

enum W2PDFError: LocalizedError {
    case missingFormImage

    var errorDescription: String? {
        switch self {
        case .missingFormImage:
            return "The W-2 form image could not be found."
        }
    }
}

enum W2PDFGenerator {
    private static let pageRect = CGRect(x: 0, y: 0, width: 792, height: 612)
    private static let pageMargin: CGFloat = 36
    private static let imageAspectRatio = 728.0 / 420.0

    static func generatePDF(for w2: W2Data) throws -> URL {
        guard let formImage = UIImage(named: "W2Form") else {
            throw W2PDFError.missingFormImage
        }

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName(for: w2))

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: fileURL) { context in
            context.beginPage()

            UIColor.white.setFill()
            context.cgContext.fill(pageRect)

            let imageRect = fittedImageRect()
            formImage.draw(in: imageRect)
            drawAnswers(w2, in: imageRect)
        }

        return fileURL
    }

    private static func fileName(for w2: W2Data) -> String {
        let baseName = w2.employeeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeName = baseName.isEmpty ? "Completed-W2" : baseName
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")

        return "TaxAssist-\(safeName)-W2.pdf"
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

    private static func drawAnswers(_ w2: W2Data, in imageRect: CGRect) {
        let address = [
            w2.streetAddress,
            "\(w2.city), \(w2.state) \(w2.zipCode)"
        ]
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")

        drawText(w2.socialSecurity, in: fieldRect(x: 0.26, y: 0.055, width: 0.19, height: 0.032, imageRect: imageRect), fontSize: 10)
        drawText(w2.employeeName, in: fieldRect(x: 0.075, y: 0.462, width: 0.43, height: 0.038, imageRect: imageRect), fontSize: 11)
        drawText(address, in: fieldRect(x: 0.075, y: 0.548, width: 0.43, height: 0.12, imageRect: imageRect), fontSize: 10)
    }

    private static func fieldRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, imageRect: CGRect) -> CGRect {
        CGRect(
            x: imageRect.minX + x * imageRect.width,
            y: imageRect.minY + y * imageRect.height,
            width: width * imageRect.width,
            height: height * imageRect.height
        )
    }

    private static func drawText(_ text: String, in rect: CGRect, fontSize: CGFloat) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty else {
            return
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]

        value.draw(in: rect, withAttributes: attributes)
    }
}

struct W2PDF: View {
    let w2: W2Data

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image("W2Form")
                .resizable()
                .scaledToFit()

            Text(w2.employeeName)
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    W2PDF(w2: W2Data(employeeName: "Alex Smith",
                     socialSecurity: "123-45-6789",
                     streetAddress: "123 Main St",
                     city: "Chicago",
                     state: "IL",
                     zipCode: "60601"))
}
