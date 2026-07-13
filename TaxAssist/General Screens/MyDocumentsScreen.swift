//
//  MyDocumentsScreen.swift
//  TaxAssist
//

import SwiftUI

enum ResumeDestination: Hashable {
    case w2(documentId: String, encryptedData: String, docName: String)
    case form1099(documentId: String, encryptedData: String, docName: String)
}

struct MyDocumentsScreen: View {
    @State private var documents: [UserDocument] = []
    @State private var isLoading = true
    
    @State private var selectedDocumentUrl: URL?
    @State private var isDownloadingPDF = false
    
    @State private var resumeDestination: ResumeDestination?
    
    @State private var documentToDelete: UserDocument?
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Fetching your documents...")
                } else if documents.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(documents) { doc in
                                documentCard(for: doc)
                            }
                        }
                        .padding()
                        .padding(.top, 12)
                        .padding(.bottom, 80)
                    }
                }
                
                if isDownloadingPDF {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView("Opening PDF...")
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("My Documents")
            .navigationDestination(item: $selectedDocumentUrl) { url in
                PDFPreviewScreen(pdfURL: url)
                    .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(item: $resumeDestination) { dest in
                switch dest {
                case .w2(let docId, let dataString, let name):
                    W2Form(customDocumentName: name, initialDocumentId: docId, encryptedData: dataString)
                        .toolbar(.hidden, for: .tabBar)
                case .form1099(let docId, let dataString, let name):
                    _099Form(initialDocumentId: docId, encryptedData: dataString, customDocumentName: name)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            .alert("Delete Document", isPresented: $showingDeleteAlert, presenting: documentToDelete) { doc in
                Button("Delete", role: .destructive) {
                    deleteDocument(doc)
                }
                Button("Cancel", role: .cancel) { }
            } message: { doc in
                Text("Are you sure you want to permanently delete '\(doc.documentName)'? This action cannot be undone.")
            }
        }
        .onAppear {
            fetchDocuments()
        }
    }

    // MARK: - Logic
    
    private func fetchDocuments() {
        Task {
            do {
                let fetchedDocs = try await DatabaseManager.shared.fetchUserDocuments()
                await MainActor.run {
                    self.documents = fetchedDocs
                    self.isLoading = false
                }
            } catch {
                print("Error fetching documents: \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }

    private func deleteDocument(_ doc: UserDocument) {
        guard let id = doc.id else { return }
        
        withAnimation {
            if let index = documents.firstIndex(where: { $0.id == id }) {
                documents.remove(at: index)
            }
        }
        
        Task {
            do {
                try await DatabaseManager.shared.deleteDocument(documentId: id)
            } catch {
                print("Failed to delete document: \(error.localizedDescription)")
                fetchDocuments()
            }
        }
    }
    
    private func openCompletedDocument(_ urlString: String) {
        guard let remoteUrl = URL(string: urlString) else { return }
        
        isDownloadingPDF = true
        
        Task {
            do {
                var request = URLRequest(url: remoteUrl)
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let localUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
                try data.write(to: localUrl)
                
                await MainActor.run {
                    self.isDownloadingPDF = false
                    self.selectedDocumentUrl = localUrl
                }
            } catch {
                print("Failed to download PDF: \(error.localizedDescription)")
                await MainActor.run { self.isDownloadingPDF = false }
            }
        }
    }

    // MARK: - UI Components
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Documents Found")
                .font(.title2.bold())
            
            Text("When you finish a tax form, it will automatically be saved and securely stored right here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func documentCard(for doc: UserDocument) -> some View {
        ZStack(alignment: .topTrailing) {
            
            Button {
                print("--- TAPPED DOCUMENT ---")
                    print("Name: \(doc.documentName)")
                    print("Status: \(doc.status.rawValue)")
                    print("FormType: \(doc.formType)")
                    print("PDF URL exists: \(doc.pdfStorageUrl != nil)")
                    print("Document ID exists: \(doc.id != nil)")
                    print("-----------------------")
                    
                    if doc.status == .completed, let urlString = doc.pdfStorageUrl {
                        print("✅ Condition Met: Opening Completed PDF")
                        openCompletedDocument(urlString)
                    } else if doc.status == .inProgress, let docId = doc.id {
                        if doc.formType == "Form W-2" {
                            print("✅ Condition Met: Resuming W-2")
                            resumeDestination = .w2(documentId: docId, encryptedData: doc.rawFormData, docName: doc.documentName)
                        } else if doc.formType == "Form 1099-NEC" {
                            print("✅ Condition Met: Resuming 1099")
                            resumeDestination = .form1099(documentId: docId, encryptedData: doc.rawFormData, docName: doc.documentName)
                        } else {
                            print("❌ SILENT FAILURE: Unknown Form Type '\(doc.formType)'")
                        }
                    } else {
                        print("❌ SILENT FAILURE: Status is \(doc.status.rawValue). If completed, PDF URL is likely missing. If In Progress, ID is missing.")
                    }
                
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(doc.status == .completed ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: doc.status == .completed ? "checkmark.seal.fill" : "doc.text.fill")
                            .foregroundColor(doc.status == .completed ? .green : .orange)
                            .font(.system(size: 24))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(doc.documentName)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .padding(.trailing, 24)
                        
                        Text("\(doc.formType) • Updated \(formattedDate(doc.lastUpdated))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(doc.status.rawValue)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(doc.status == .completed ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                            .foregroundColor(doc.status == .completed ? .green : .orange)
                            .clipShape(Capsule())
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            }
            .buttonStyle(.plain)
            
            Button {
                documentToDelete = doc
                showingDeleteAlert = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(uiColor: .systemGray3))
                    .background(Circle().fill(Color(uiColor: .systemGroupedBackground)))
                    .font(.system(size: 24))
            }
            .offset(x: 10, y: -10)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    MyDocumentsScreen()
}
