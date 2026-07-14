//
//  UniversalPDFGenerator.swift
//  TaxAssist
//

import SwiftUI
import UIKit
import PDFKit

// MARK: - Reusable UI Components

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) { }
}

// MARK: - PDF Errors

enum PDFGenerationError: LocalizedError {
    case missingFormPDF(String)
    case unableToOpenPDF(String)
    case missingPDFPage

    var errorDescription: String? {
        switch self {
        case .missingFormPDF(let name):
            return "The PDF '\(name).pdf' could not be found."

        case .unableToOpenPDF(let name):
            return "The PDF '\(name).pdf' could not be opened."

        case .missingPDFPage:
            return "The PDF does not contain a page."
        }
    }
}

// MARK: - Universal PDF Generator

enum UniversalPDFGenerator {

    static func generate(
        baseImageName: String,
        outputFileName: String,
        drawFields: (_ pageRect: CGRect) -> Void
    ) throws -> URL {

        // Find PDF in app bundle
        print("Looking for PDF:", baseImageName)

        print(
            "PDF URL:",
            Bundle.main.url(
                forResource: baseImageName,
                withExtension: "pdf"
            ) as Any
        )
        guard let pdfURL = Bundle.main.url(
            forResource: baseImageName,
            withExtension: "pdf"
        ) else {
            throw PDFGenerationError.missingFormPDF(baseImageName)
        }

        // Open PDF

        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            throw PDFGenerationError.unableToOpenPDF(baseImageName)
        }

        guard let pdfPage = pdfDocument.page(at: 0) else {
            throw PDFGenerationError.missingPDFPage
        }

        // Get exact PDF page size

        let pageRect = pdfPage.bounds(for: .mediaBox)

        // Create output URL

        let fileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                safeFileName(from: outputFileName)
            )

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        // Create PDF renderer using original PDF size

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: fileURL) { context in

            context.beginPage()

            let cgContext = context.cgContext

            // Save graphics state

            cgContext.saveGState()

            // PDF coordinate system correction

            cgContext.translateBy(
                x: 0,
                y: pageRect.height
            )

            cgContext.scaleBy(
                x: 1,
                y: -1
            )

            // Draw original PDF page

            pdfPage.draw(
                with: .mediaBox,
                to: cgContext
            )

            // Restore normal UIKit coordinates

            cgContext.restoreGState()

            // Draw form answers

            drawFields(pageRect)
        }

        return fileURL
    }

    // MARK: - Field Coordinates

    static func fieldRect(
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        inside pageRect: CGRect
    ) -> CGRect {

        CGRect(
            x: pageRect.minX + x * pageRect.width,
            y: pageRect.minY + y * pageRect.height,
            width: width * pageRect.width,
            height: height * pageRect.height
        )
    }

    // MARK: - Draw Text

    static func drawText(
        _ text: String,
        in rect: CGRect,
        fontSize: CGFloat = 10
    ) {

        let value = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else {
            return
        }

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineBreakMode = .byClipping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]

        value.draw(
            in: rect,
            withAttributes: attributes
        )
    }

    // MARK: - File Name

    private static func safeFileName(
        from requestedName: String
    ) -> String {

        let safeName = requestedName
            .components(
                separatedBy: CharacterSet.alphanumerics.inverted
            )
            .filter { !$0.isEmpty }
            .joined(separator: "-")

        return "\(safeName).pdf"
    }
}
