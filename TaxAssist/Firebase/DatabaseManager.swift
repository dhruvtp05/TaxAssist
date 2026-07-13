import Foundation
import FirebaseFirestore
import FirebaseAuth

enum DocumentStatus: String, Codable {
    case inProgress = "In Progress"
    case completed = "Completed"
}

struct UserDocument: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let documentName: String
    let formType: String
    let status: DocumentStatus
    let lastUpdated: Date
    let pdfStorageUrl: String?
    let rawFormData: String
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func saveDocument(documentId: String?, documentName: String, formType: String, status: DocumentStatus, pdfUrl: String? = nil, rawData: String) async throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let encryptedData = try SecurityManager.shared.encrypt(rawData)
        
        let collectionRef = db.collection("users").document(userId).collection("documents")
        
        let docRef = documentId != nil ? collectionRef.document(documentId!) : collectionRef.document()
        
        let newDoc = UserDocument(
            userId: userId,
            documentName: documentName,
            formType: formType,
            status: status,
            lastUpdated: Date(),
            pdfStorageUrl: pdfUrl,
            rawFormData: encryptedData
        )
        
        try docRef.setData(from: newDoc)
        
        return docRef.documentID
    }
    
    func fetchUserDocuments() async throws -> [UserDocument] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("documents")
            .order(by: "lastUpdated", descending: true)
            .getDocuments()
        
        var fetchedDocs: [UserDocument] = []
        
        for document in snapshot.documents {
            do {
                let doc = try document.data(as: UserDocument.self)
                fetchedDocs.append(doc)
            } catch {
                print("❌ Failed to decode document \(document.documentID): \(error)")
            }
        }
        
        return fetchedDocs
    }
    
    func markDocumentAsCompleted(documentId: String, pdfUrl: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let docRef = db.collection("users").document(userId).collection("documents").document(documentId)
        try await docRef.updateData([
            "status": DocumentStatus.completed.rawValue,
            "pdfStorageUrl": pdfUrl
        ])
    }
    
    func deleteDocument(documentId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let docRef = db.collection("users").document(userId).collection("documents").document(documentId)
        try await docRef.delete()
    }
}
