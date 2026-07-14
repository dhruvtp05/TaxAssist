import SwiftUI
import PDFKit

// MARK: - The SwiftUI Screen
struct PDFPreviewScreen: View {
    let pdfURL: URL
    @State private var showingShareSheet = false

    var body: some View {
        PDFKitView(url: pdfURL)
            .edgesIgnoringSafeArea(.bottom)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Document Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [pdfURL])
            }
    }
}

// MARK: - The PDFKit Wrapper
struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()

        pdfView.document = PDFDocument(url: url)

        // Do not automatically fit the PDF to the screen
        pdfView.autoScales = false

        // Show the PDF at its natural scale
        pdfView.scaleFactor = 1.0

        // Allow zooming
        pdfView.minScaleFactor = 0.5
        pdfView.maxScaleFactor = 5.0

        // One continuous document
        pdfView.displayMode = .singlePageContinuous

        // Allow movement in both directions
        pdfView.displayDirection = .vertical

        pdfView.backgroundColor = .systemGroupedBackground

        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}
