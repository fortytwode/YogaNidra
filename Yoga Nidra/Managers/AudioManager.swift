import AVFoundation
import MediaPlayer
import SwiftUI

@MainActor
final class AudioManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    static let shared = AudioManager()
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var srubPostion = 0.0
    @Published var currentPlayingSession: YogaNidraSession?
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
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
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
    
    func onStopSession() {
        stop()
        updateNowPlayingInfo()
    }
    
    func onPlaySession(session: YogaNidraSession) throws {
        if currentPlayingSession == session {
            onResumeSession()
        } else {
            try play(audioFileWithExtension: session.audioFileName)
            currentPlayingSession = session
            updateNowPlayingInfo()
        }
    }
    
    // MARK: - Playback Controls
    func play(audioFileWithExtension fileName: String, loop: Bool = false) throws {
        // First try mp3
        if let path = Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".mp3", with: ""), 
                                     ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            if loop {
                audioPlayer?.numberOfLoops = -1
            }
            audioPlayer?.play()
            isPlaying = true
            startTimer()
            return
        }
        
        // Then try m4a
        if let path = Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".m4a", with: ""), 
                                     ofType: "m4a") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            startTimer()
            return
        }
        
        print("❌ Could not find audio file:", fileName)
        throw AudioError.fileNotFound
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
    
    private func pause() {
        audioPlayer?.pause()
        isPlaying = false
        timer?.invalidate()
    }
    
    private func resume() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    public func stop() {
        audioPlayer?.stop()
        isPlaying = false
        audioPlayer?.currentTime = 0
        updateCurrentPlayerTime(time: 0)
        currentPlayingSession = nil
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
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = session.category.rawValue
        
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
}
