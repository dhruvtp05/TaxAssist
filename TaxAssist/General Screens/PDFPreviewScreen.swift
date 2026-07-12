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
        pdfView.autoScales = true 
        pdfView.displayMode = .singlePageContinuous
        pdfView.backgroundColor = .systemGroupedBackground
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}
