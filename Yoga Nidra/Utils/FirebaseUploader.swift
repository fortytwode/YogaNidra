import Foundation
import FirebaseStorage

/// Utility class to help upload meditation files to Firebase Storage
@MainActor
final class FirebaseUploader {
    static let shared = FirebaseUploader()
    private let storage = Storage.storage()
    
    private init() {}
    
    func uploadMeditationFile(localPath: String) async throws -> String {
        let fileURL = URL(fileURLWithPath: localPath)
        let fileName = fileURL.lastPathComponent
        
        // Create a reference to the meditations folder
        let meditationsRef = storage.reference().child("meditations")
        let fileRef = meditationsRef.child(fileName)
        
        print("📤 Starting upload of \(fileName)...")
        
        // Create metadata
        let metadata = StorageMetadata()
        metadata.contentType = "audio/mpeg"
        
        // Upload the file
        _ = try await fileRef.putFileAsync(from: fileURL, metadata: metadata) { progress in
            if let progress = progress {
                let percent = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100
                print("Upload progress: \(Int(percent))%")
            }
        }
        
        // Get the download URL
        let downloadURL = try await fileRef.downloadURL()
        print("✅ Upload complete! File available at: \(downloadURL.absoluteString)")
        return downloadURL.absoluteString
    }
}
