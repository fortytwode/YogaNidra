import AVFoundation
import MediaPlayer

@MainActor
final class AudioManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    static let shared = AudioManager()
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0.0
    
    private var audioPlayer: AVAudioPlayer?
    private var currentPlayingSession: YogaNidraSession?

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
    
    func onPlaySession(session: YogaNidraSession) {
        if isPlaying {
            pause()
        } else {
            if currentPlayingSession == session {
                resume()
            } else {
                play(audioFileWithExtension: session.audioFileName)
                currentPlayingSession = session
            }
        }
    }
    
    // MARK: - Playback Controls
    private func play(audioFileWithExtension: String) {
        let splits = audioFileWithExtension.split(separator: ".")
        let fileName = splits.first
        let fileExtension = splits.last
        guard let fileName,
              let fileExtension,
              let url = Bundle.main.url(forResource: String(fileName), withExtension: String(fileExtension)) else {
            print("Audio file not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            updateNowPlayingInfo()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    private func pause() {
        audioPlayer?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }
    
    private func resume() {
        audioPlayer?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    private func stop() {
        audioPlayer?.stop()
        isPlaying = false
        audioPlayer?.currentTime = 0
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
}
