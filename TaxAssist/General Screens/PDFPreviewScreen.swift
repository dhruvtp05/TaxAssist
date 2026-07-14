import SwiftUI
import PDFKit

struct PDFPreviewScreen: View {
    let pdfURL: URL
    var documentId: String? = nil
    
    @State private var showingShareSheet = false
    @State private var isCompleting = false
    @State private var showSuccess = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if showSuccess {
                completionView
            } else {
                VStack(spacing: 0) {
                    PDFKitView(url: pdfURL)
                    
                    if let docId = documentId {
                        bottomBar(docId: docId)
                    }
                }
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
    }
    
    // MARK: - UI Components
    
    private func bottomBar(docId: String) -> some View {
        VStack {
            Button {
                completeDocument(docId: docId)
            } label: {
                if isCompleting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Approve & Complete")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .disabled(isCompleting)
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 90)
        .background(
            Color(uiColor: .systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
        )
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Text("Document Completed!")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Your tax form has been securely encrypted and saved to your cloud records.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button {
                NavigationUtil.popToRootView()
            } label: {
                Text("Go to Home Screen")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            .padding(.bottom, 90)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Logic
    
    private func completeDocument(docId: String) {
        isCompleting = true
        Task {
            do {
                let permanentUrl = try await StorageManager.shared.uploadPDF(localFileUrl: pdfURL, formName: docId)
                
                try await DatabaseManager.shared.markDocumentAsCompleted(documentId: docId, pdfUrl: permanentUrl)
                
                await MainActor.run {
                    isCompleting = false
                    withAnimation(.spring()) {
                        showSuccess = true
                    }
                }
            } catch {
                print("Failed to complete document: \(error.localizedDescription)")
                await MainActor.run { isCompleting = false }
            }
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

// MARK: - Navigation Helper
struct NavigationUtil {
    static func popToRootView() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else { return }
        
        func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
            guard let viewController = viewController else { return nil }
            if let navigationController = viewController as? UINavigationController {
                return navigationController
            }
            for childViewController in viewController.children {
                return findNavigationController(viewController: childViewController)
            }
            return nil
        }
        
        if let navigationController = findNavigationController(viewController: rootViewController) {
            navigationController.popToRootViewController(animated: true)
        }
    }
}