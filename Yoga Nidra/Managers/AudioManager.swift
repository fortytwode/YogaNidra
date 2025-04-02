import AVFoundation
import MediaPlayer
import SwiftUI
import FirebaseStorage
import FirebaseAnalytics
import FBSDKCoreKit

final class Debouncer {
    
    typealias Handler = () async throws -> Void
    
    private let delay: Duration
    private var task: Task<Void, Error>?
    
    init(delay: Duration) {
        self.delay = delay
    }
    
    func debounce(waitForDelay: Bool = true, _ handler: @escaping Handler) {
        task?.cancel()
        task = Task {
            if waitForDelay {
                try await Task.sleep(for: delay)
            }
            try await handler()
        }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
}

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
    
    // MARK: - Analytics Tracking Properties
    private var sessionStartTime: Date?
    private var lastSessionId: String?
    private var lastCategory: String?
    private var lastTitle: String?
    
    // MARK: - Private Properties
    private let audioEngine = AudioEngine.shared
    private var timeObserverToken: Any?
    private var preparedSession: YogaNidraSession?
    private var isPlayingOnboarding: Bool = false
    private let seekDebouncer = Debouncer(delay: .seconds(1))
    
    // MARK: - Initialization
    private init() {
        setupRemoteCommandCenter()
        
        // Add observer for playback completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaybackFinished),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handlePlaybackFinished() {
        guard OnboardingManager.shared.isOnboardingCompleted else { return }
        stop(mode: .clearSession)
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
        stop()
        isPlayingOnboarding = false
    }
    
    /// Plays a meditation session
    func play(_ session: YogaNidraSession) async {
        do {
            // Stop any existing playback but don't clear session yet
            stop(mode: .switchSession)
            
            isLoading = true
            errorMessage = nil
            currentPlayingSession = session
            
            // Update Now Playing state immediately
            updateNowPlayingInfo()
            
            // Start progress tracking
            ProgressManager.shared.audioSessionStarted(session: session)
            
            // Track session start
            sessionStartTime = Date()
            lastSessionId = session.id
            lastCategory = session.category.id
            lastTitle = session.title
            
            // Log meditation started event
            FirebaseManager.shared.logMeditationStarted(
                sessionId: session.id,
                duration: TimeInterval(session.duration),
                category: session.category.id
            )
            
            // Try to get local URL first
            if let localURL = session.localURL, FileManager.default.fileExists(atPath: localURL.path) {
                try await playFromURL(localURL)
            } else {
                // Download from Firebase if not available locally
                let remoteURL = try await FirebaseManager.shared.getMeditationURL(
                    fileFolder: session.audioFileFolder,
                    fileName: session.audioFileName
                )
                try await playFromURL(remoteURL)
            }
            
            isLoading = false
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    /// Pauses the current playback
    func pause() async {
        ProgressManager.shared.audioSessionEnded()
        audioEngine.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }
    
    /// Resumes the current playback
    func resume() async {
        ProgressManager.shared.audioSessionStarted(session: currentPlayingSession)
        audioEngine.play()
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    /// Stops playback and optionally resets state
    func stop(mode: SessionClearMode = .clearSession) {
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
            audioEngine.stop()
            
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
        
        ProgressManager.shared.audioSessionEnded()
        
        // Track session end
        if let sessionStartTime = sessionStartTime, let sessionId = lastSessionId, let category = lastCategory {
            let sessionDuration = Date().timeIntervalSince(sessionStartTime)
            
            // Log meditation completed event
            FirebaseManager.shared.logMeditationCompleted(
                sessionId: sessionId,
                duration: sessionDuration,
                category: category
            )
            
            // Track first meditation completed with Facebook
            checkAndTrackFirstMeditationCompleted(
                sessionId: sessionId,
                durationMinutes: Int(sessionDuration / 60),
                category: category
            )
            
            // Also log to standard Firebase event for backward compatibility
            Analytics.logEvent("session_completed", parameters: [
                "session_id": sessionId,
                "category": category,
                "title": lastTitle ?? "",
                "duration": sessionDuration
            ])
            
            // Track meditation completion with Superwall
            SuperwallManager.shared.trackEvent("meditation_completed")
            
            self.sessionStartTime = nil
            lastSessionId = nil
            lastCategory = nil
            lastTitle = nil
        }
    }
    
    // MARK: - Session Management
    
    func prepareSession(_ session: YogaNidraSession) {
        guard !isLoading else { return }
        preparedSession = session
    }
    
    func startPreparedSession() async {
        guard let session = preparedSession,
              !isLoading else { return }
        await play(session)
    }
    
    func dismissDetailView() {
        // Only clear prepared if not playing
        if currentPlayingSession == nil {
            preparedSession = nil
        }
    }
    
    // MARK: - Time Control
    
    func onScrubberSeek(progress: Double) {
        let time = duration * progress
        seek(to: time, immidiate: true)
    }
    
    func seek(to time: TimeInterval, immidiate: Bool = true) {
        seekDebouncer.debounce(waitForDelay: !immidiate) { [weak self] in
            self?.audioEngine.seek(to: time)
        }
        self.currentTime = time
        self.progress = time / duration
        updateNowPlayingInfo()
    }
    
    func skipForward() async {
        let newTime = min(currentTime + 15, duration)  // 15 seconds forward
        seek(to: newTime)
    }
    
    func skipBackward() async {
        let newTime = max(currentTime - 15, 0)  // 15 seconds backward
        seek(to: newTime)
    }
    
    // MARK: - Private Methods
    
    private func setupTimeObserver() {
        if let token = timeObserverToken {
            audioEngine.removeTimeObserver(token)
            timeObserverToken = nil
        }
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
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
            self?.seek(to: event.positionTime)
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
                    Task {
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
    
    // MARK: - Facebook Event Tracking
    
    private func checkAndTrackFirstMeditationCompleted(sessionId: String, durationMinutes: Int, category: String) {
        let defaults = UserDefaults.standard
        let hasCompletedFirstMeditation = defaults.bool(forKey: "hasCompletedFirstMeditation")
        
        if !hasCompletedFirstMeditation {
            // This is their first meditation
            FacebookEventTracker.shared.trackFirstMeditationCompleted(
                meditationId: sessionId,
                durationMinutes: durationMinutes
            )
            
            // Mark that they've completed their first meditation
            defaults.set(true, forKey: "hasCompletedFirstMeditation")
        }
    }
}
