import AVFoundation
import MediaPlayer
import SwiftUI
import FirebaseStorage

@MainActor
final class AudioManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    static let shared = AudioManager()
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var srubPostion = 0.0
    @Published var currentPlayingSession: YogaNidraSession?
    @Published private(set) var isLoading: Bool = false
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    @MainActor
    private override init() {
        super.init()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        setupAudioSession()
        setupRemoteCommandCenter()
        setupNotifications()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            print("✅ Audio session setup successful")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Remote Command Center
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.resume()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.nextTrack()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.previousTrack()
            return .success
        }
    }
    
    func onPauseSession() {
        pause()
        updateNowPlayingInfo()
    }
    
    func onResumeSession() {
        resume()
        updateNowPlayingInfo()
    }
    
    public func onStopSession() {
        stop()
        updateNowPlayingInfo()
    }
    
    func onPlaySession(session: YogaNidraSession) async throws {
        guard !isLoading else { return }
        isLoading = true
        
        defer { isLoading = false }
        
        // First deactivate current session if any
        if audioPlayer != nil {
            stop()
        }
        
        if currentPlayingSession == session {
            onResumeSession()
        } else {
            print("🎵 Starting playback of: \(session.title)")
            let fileName = session.audioFileName
            if isFileCached(fileName) {
                print("📂 Using cached file")
                try await play(audioFileWithExtension: fileName)
            } else {
                print("⬇️ Downloading from Firebase")
                let localURL = try await downloadFromFirebase(fileName: fileName)
                try await play(audioFileWithExtension: localURL.lastPathComponent)
            }
            currentPlayingSession = session
            updateNowPlayingInfo()
            ProgressManager.shared.audioSessionStarted()
            print("✅ Playback setup complete")
        }
    }
    
    // MARK: - Playback Controls
    func play(audioFileWithExtension fileName: String, loop: Bool = false) async throws {
        let localURL = getLocalFileURL(for: fileName)
        if FileManager.default.fileExists(atPath: localURL.path) {
            print("🎵 Creating audio player with local file")
            audioPlayer = try AVAudioPlayer(contentsOf: localURL)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = loop ? -1 : 0
            audioPlayer?.prepareToPlay()
            resume()
            startTimer()
            print("✅ Audio player created and started")
        } else {
            print("❌ Audio file not found at: \(localURL.path)")
            throw AudioError.fileNotFound
        }
    }
    
    func skip(_ direction: SkipDirection, by seconds: TimeInterval) {
        guard let audioPlayer else { return }
        let newTime: TimeInterval
        switch direction {
        case .forward:
            newTime = min(audioPlayer.currentTime + seconds, audioPlayer.duration)
        case .backward:
            newTime = max(audioPlayer.currentTime - seconds, 0)
        }
        audioPlayer.currentTime = newTime
        updateCurrentPlayerTime(time: newTime)
    }
    
    func onScrub(fraction: Double) {
        guard let audioPlayer else { return }
        let newTime: TimeInterval = fraction * audioPlayer.duration
        audioPlayer.currentTime = newTime
        updateCurrentPlayerTime(time: newTime)
    }
    
    private func resume() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
        updateNowPlayingInfo()
    }
    
    private func pause() {
        audioPlayer?.pause()
        isPlaying = false
        timer?.invalidate()
        updateNowPlayingInfo()
    }
    
    public func stop() {
        ProgressManager.shared.audioSessionEnded()
        audioPlayer?.stop()
        isPlaying = false
        timer?.invalidate()
        currentPlayingSession = nil
        currentTime = 0
        updateNowPlayingInfo()
    }
    
    private func nextTrack() {
        // Implement logic for next track playback
        print("Next track")
    }
    
    private func previousTrack() {
        // Implement logic for previous track playback
        print("Previous track")
    }
    
    // MARK: - Now Playing Info
    private func updateNowPlayingInfo() {
        guard let audioPlayer = audioPlayer, let session = currentPlayingSession else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = session.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = session.instructor
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = session.category.id
        
        if let artworkImage = UIImage(named: session.thumbnailUrl) { // Replace with your album art
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in
                return artworkImage
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupNotifications() {
        print("🔔 Setting up audio notifications...")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        print("✅ Audio notifications configured")
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                resume()
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            pause()
        default:
            break
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                self?.updateCurrentPlayerTime(time: self?.audioPlayer?.currentTime)
                self?.updateNowPlayingInfo()
            }
        }
    }
    
    private func updateCurrentPlayerTime(time: TimeInterval?) {
        guard let time, let audioPlayer else { return }
        let totalDuration = audioPlayer.duration
        let scrubTime = Double(time) / Double(totalDuration)
        withAnimation {
            currentTime = time
            srubPostion = scrubTime
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
        do {
            // Get download URL from Firebase
            let downloadURL = try await FirebaseManager.shared.getMeditationURL(fileName: fileName)
            
            // Create a local file URL in the documents directory
            let localURL = getLocalFileURL(for: fileName)
            
            // Download the file
            let (tempURL, _) = try await URLSession.shared.download(from: downloadURL)
            
            // Move the downloaded file to our documents directory
            if FileManager.default.fileExists(atPath: localURL.path) {
                try FileManager.default.removeItem(at: localURL)
            }
            try FileManager.default.moveItem(at: tempURL, to: localURL)
            
            return localURL
        } catch {
            throw AudioError.firebaseDownloadFailed(error)
        }
    }
    
    // Clean up
    deinit {
        timer?.invalidate()
    }
    
    enum SkipDirection {
        case forward
        case backward
    }
}

enum AudioError: Error {
    case fileNotFound
    case firebaseDownloadFailed(Error)
    case playbackFailed
    
    var localizedDescription: String {
        switch self {
        case .fileNotFound:
            return "Audio file not found"
        case .firebaseDownloadFailed(let error):
            return "Failed to download from Firebase: \(error.localizedDescription)"
        case .playbackFailed:
            return "Failed to start audio playback"
        }
    }
}
