import AVFoundation
import MediaPlayer
import SwiftUI
import FirebaseStorage

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    // MARK: - Types
    
    enum SessionClearMode {
        case keepSession     // Just stop playback
        case clearSession    // Full reset (for onboarding)
        case switchSession   // For changing sessions
    }
    
    // MARK: - Published Properties
    @Published var isPlaying: Bool = false
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var errorMessage: String?
    @Published private(set) var currentPlayingSession: YogaNidraSession?
    @Published private(set) var isDetailViewPresented: Bool = false
    
    // MARK: - Private Properties
    private let audioEngine = AudioEngine.shared
    private var timeObserverToken: Any?
    private var preparedSession: YogaNidraSession?
    
    // MARK: - Initialization
    private init() {
        setupRemoteCommandCenter()
    }
    
    // MARK: - Public API
    
    /// Plays a meditation session
    @MainActor
    func play(_ session: YogaNidraSession) async {
        do {
            // Stop any existing playback but don't clear session yet
            await stop(mode: .switchSession)
            
            isLoading = true
            errorMessage = nil
            currentPlayingSession = session
            
            // Try to get local URL first
            if session.isDownloaded, let localURL = session.localURL {
                try await playFromURL(localURL)
            } else {
                // Fallback to streaming from Firebase
                let downloadURL = try await downloadFromFirebase(fileName: session.audioFileName)
                try await playFromURL(downloadURL)
            }
            
            currentPlayingSession = session
            isPlaying = true
            
        } catch {
            print("Failed to play session: \(error.localizedDescription)")
            isLoading = false
            errorMessage = error.localizedDescription
            currentPlayingSession = nil
        }
    }
    
    /// Pauses the current playback
    func pause() async {
        await MainActor.run {
            audioEngine.pause()
            isPlaying = false
            updateNowPlayingInfo()
        }
    }
    
    /// Resumes the current playback
    func resume() async {
        await MainActor.run {
            audioEngine.play()
            isPlaying = true
            updateNowPlayingInfo()
        }
    }
    
    /// Stops playback and optionally resets state
    func stop(mode: SessionClearMode = .keepSession) async {
        await MainActor.run {
            // Stop playback
            audioEngine.pause()
            
            // Clean up time observer
            if let token = timeObserverToken {
                audioEngine.removeTimeObserver(token)
                timeObserverToken = nil
            }
            
            // Handle session state based on mode
            switch mode {
            case .keepSession:
                // Just stop playback, keep session
                isPlaying = false
                
            case .clearSession:
                // Full reset (for onboarding)
                currentPlayingSession = nil
                preparedSession = nil
                isPlaying = false
                
            case .switchSession:
                // Keep prepared session if exists
                if preparedSession == nil {
                    currentPlayingSession = nil
                }
                isPlaying = false
            }
            
            // Always reset these
            currentTime = 0
            duration = 0
            progress = 0
            isLoading = false
            errorMessage = nil
            
            // Update now playing info
            updateNowPlayingInfo()
        }
    }
    
    // MARK: - Session Management
    
    func prepareSession(_ session: YogaNidraSession) {
        guard !isLoading else { return }
        preparedSession = session
        isDetailViewPresented = true
    }
    
    @MainActor
    func startPreparedSession() async {
        guard let session = preparedSession,
              !isLoading else { return }
        await play(session)
    }
    
    func dismissDetailView() {
        isDetailViewPresented = false
        // Only clear prepared if not playing
        if currentPlayingSession == nil {
            preparedSession = nil
        }
    }
    
    // MARK: - Time Control
    
    func seek(to time: TimeInterval) async {
        await audioEngine.seek(to: time)
        self.currentTime = time
        self.progress = time / duration
        updateNowPlayingInfo()
    }
    
    func skipForward() async {
        await audioEngine.skipForward()
        self.currentTime = audioEngine.currentTime
        self.progress = currentTime / duration
        updateNowPlayingInfo()
    }
    
    func skipBackward() async {
        await audioEngine.skipBackward()
        self.currentTime = audioEngine.currentTime
        self.progress = currentTime / duration
        updateNowPlayingInfo()
    }
    
    // MARK: - Private Methods
    
    private func setupTimeObserver() {
        if let token = timeObserverToken {
            audioEngine.removeTimeObserver(token)
            timeObserverToken = nil
        }
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = audioEngine.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            self.duration = self.audioEngine.duration
            if self.duration > 0 {
                self.progress = self.currentTime / self.duration
            }
            self.updateNowPlayingInfo()
        }
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.resume()
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.pause()
            }
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                if self?.isPlaying == true {
                    await self?.pause()
                } else {
                    await self?.resume()
                }
            }
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let session = currentPlayingSession else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = session.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Yoga Nidra"
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Firebase Storage
    
    private func getLocalFileURL(for fileName: String) -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(fileName)
    }
    
    private func isFileCached(_ fileName: String) -> Bool {
        let localURL = getLocalFileURL(for: fileName)
        return FileManager.default.fileExists(atPath: localURL.path)
    }
    
    private func downloadFromFirebase(fileName: String) async throws -> URL {
        let localURL = getLocalFileURL(for: fileName)
        
        // If file exists locally, return its URL
        if FileManager.default.fileExists(atPath: localURL.path) {
            return localURL
        }
        
        // Download from Firebase Storage
        let storage = Storage.storage()
        let audioRef = storage.reference().child("meditations/\(fileName)")
        
        // Use a task to ensure we only have one download at a time
        return try await withCheckedThrowingContinuation { continuation in
            let task = audioRef.write(toFile: localURL) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    print("✅ File downloaded successfully")
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: NSError(domain: "AudioManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error during download"]))
                }
            }
            
            // If there's already a task running, cancel it
            task.observe(.progress) { _ in
                if task.description.contains("was already running") {
                    task.cancel()
                }
            }
        }
    }
    
    private func playFromURL(_ url: URL) async throws {
        // Prepare audio engine for playback
        await withCheckedContinuation { continuation in
            audioEngine.prepareForPlayback(url: url) { [weak self] result in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                
                switch result {
                case .success:
                    self.setupTimeObserver()
                    Task { @MainActor in
                        await self.resume()
                    }
                    self.isLoading = false
                    print("✅ Playback started successfully")
                    
                case .failure(let error):
                    print("❌ Failed to prepare playback: \(error)")
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                continuation.resume()
            }
        }
    }
}
