import Foundation

@MainActor
class DownloadManager: ObservableObject {
    
    static let shared = DownloadManager()
    private let storeManager = StoreManager.shared
    
    func downloadSession(_ yogaNidraSession: YogaNidraSession) async throws {
        // Log the start of the download process
        print("📥 Starting download for session: \(yogaNidraSession.fileName).\(yogaNidraSession.fileExtension)")
        
        // Check subscription status asynchronously
        guard storeManager.isSubscribed else {
            print("❌ User is not subscribed. Download aborted.")
            return
        }
        
        // Get file URLs
        guard let to = fileURLForSession(yogaNidraSession),
              let path = Bundle.main.path(forResource: yogaNidraSession.fileName,
                                          ofType: yogaNidraSession.fileExtension) else {
            print("⚠️ File paths could not be resolved. Check file name or extension.")
            return
        }
        
        let from = URL(fileURLWithPath: path)
        
        // Attempt file copy
        do {
            try FileManager.default.copyItem(at: from, to: to)
            print("✅ Successfully copied file to \(to.path)")
        } catch {
            print("❌ Error copying file: \(error.localizedDescription)")
            throw error
        }
        objectWillChange.send()
    }
    
    func fileURLForSession(_ yogaNidraSession: YogaNidraSession) -> URL? {
        guard let storageFolder = storageFolder() else {
            print("⚠️ Unable to locate storage folder.")
            return nil
        }
        let fileURL = storageFolder.appendingPathComponent("\(yogaNidraSession.fileName).\(yogaNidraSession.fileExtension)")
        print("📂 Resolved file URL: \(fileURL.path)")
        return fileURL
    }
    
    private func storageFolder() -> URL? {
        let fileManager = FileManager.default
        guard let folder = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("YogaNidraSessions") else {
            print("❌ Could not resolve documents directory.")
            return nil
        }
        
        // Attempt to create the folder if it doesn’t exist
        do {
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            print("📁 Created storage folder at \(folder.path)")
        } catch {
            print("⚠️ Error creating storage folder: \(error.localizedDescription)")
            return nil
        }
        return folder
    }
}
