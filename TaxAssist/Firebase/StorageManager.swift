import Foundation
import FirebaseStorage
import FirebaseAuth

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    func uploadPDF(localFileUrl: URL, formName: String) async throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let safeFileName = "\(formName)-\(UUID().uuidString).pdf"
        let fileRef = storage.child("users/\(userId)/documents/\(safeFileName)")
        
        let pdfData = try Data(contentsOf: localFileUrl)
        
        _ = try await fileRef.putDataAsync(pdfData)
        
        let downloadUrl = try await fileRef.downloadURL()
        return downloadUrl.absoluteString
    }
}
