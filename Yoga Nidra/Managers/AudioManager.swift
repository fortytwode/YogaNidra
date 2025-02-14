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
    private var isPlayingOnboarding: Bool = false
    
    // MARK: - Initialization
    private init() {
        setupRemoteCommandCenter()
        
        // Observe audio engine state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioEngineDidStartPlaying),
            name: .audioEngineDidStartPlaying,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioEngineDidPause),
            name: .audioEngineDidPause,
            object: nil
        )
        
        // Add completion observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioEngineDidFinish),
            name: .audioEngineDidFinishPlaying,
            object: nil
        )
        
        // Add observer for playback completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaybackFinished),
            name: .audioEngineDidFinishPlaying,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleAudioEngineDidStartPlaying() {
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    @objc private func handleAudioEngineDidPause() {
        isPlaying = false
        updateNowPlayingInfo()
    }
    
    @objc private func handlePlaybackFinished() {
        Task { @MainActor in
            if let session = currentPlayingSession {
                await ProgressManager.shared.audioSessionCompleted()
            }
        }
    }
    
    @objc private func handleAudioEngineDidFinish() {
        print("🎵 Audio finished playing")
        guard let session = currentPlayingSession else {
            print("❌ No current session")
            return
        }
        print("✅ Completing session: \(session.title)")
        
        Task {
            await ProgressManager.shared.audioSessionCompleted()
        }
    }
    
    // MARK: - Public API
    func startOnboardingMusic() {
        guard let fileURL = Bundle.main.url(forResource: "calm-ambient", withExtension: "mp3"), !isPlayingOnboarding else {
            return
        }
        Task {
            try await playFromURL(fileURL)
            isPlayingOnboarding = true
        }
    }
    
    func stopOnboardingMusic() {
        guard isPlayingOnboarding else { return }
        Task {
            await stop()
            isPlayingOnboarding = false
        }
    }
    
    /// Plays a meditation session
    @MainActor
    func play(_ session: YogaNidraSession) async {
        do {
            // Stop any existing playback but don't clear session yet
            await stop(mode: .switchSession)
            
            isLoading = true
            errorMessage = nil
            currentPlayingSession = session
            
            // Update Now Playing state immediately
            updateNowPlayingInfo()
            
            // Start progress tracking
            ProgressManager.shared.audioSessionStarted()
            
            // Try to get local URL first
            if let localURL = session.localURL, FileManager.default.fileExists(atPath: localURL.path) {
                try await playFromURL(localURL)
            } else {
                // Download from Firebase if not available locally
                let remoteURL = try await FirebaseManager.shared.getMeditationURL(fileName: session.audioFileName)
                try await playFromURL(remoteURL)
            }
            
            isLoading = false
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
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
        audioEngine.seek(to: time)
        self.currentTime = time
        self.progress = time / duration
        updateNowPlayingInfo()
    }
    
    func skipForward() async {
        let newTime = min(currentTime + 15, duration)  // 15 seconds forward
        await seek(to: newTime)
    }
    
    func skipBackward() async {
        let newTime = max(currentTime - 15, 0)  // 15 seconds backward
        await seek(to: newTime)
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
        
        // Clear existing handlers
        [commandCenter.playCommand,
         commandCenter.pauseCommand,
         commandCenter.skipBackwardCommand,
         commandCenter.skipForwardCommand,
         commandCenter.changePlaybackPositionCommand].forEach { $0.removeTarget(nil) }
        
        // Enable commands with 15 second intervals
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        
        // Setup new handlers
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task {
                await self?.resume()
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task {
                await self?.pause()
            }
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            Task {
                await self?.skipBackward()
            }
            return .success
        }
        
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            Task {
                await self?.skipForward()
            }
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            Task {
                await self?.seek(to: event.positionTime)
            }
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let session = currentPlayingSession else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = session.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Yoga Nidra"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Add high-quality artwork
        if let image = UIImage(named: session.thumbnailUrl) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        // Update Now Playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        // Update playback state for app icon indicator
        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
        
        // Ensure audio session is active
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Failed to activate audio session: \(error)")
        }
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
    
    private func activateAudioSession() {
        // Removed duplicate audio session activation
        // Now handled by AudioEngine
    }
    
    private func deactivateAudioSession() {
        // Removed duplicate audio session deactivation
        // Now handled by AudioEngine
    }
}
