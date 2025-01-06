import AVFoundation
import MediaPlayer

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var currentTitle: String?
    private var currentArtwork: String?
    
    override init() {
        super.init()
        print("🎵 AudioManager: Initializing...")
        setupAudioSession()
        setupRemoteTransportControls()
        setupNotifications()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowAirPlay]
            )
            try session.setActive(true)
            print("✅ AudioSession: Successfully configured for background playback")
        } catch {
            print("❌ AudioSession Error: \(error.localizedDescription)")
        }
    }
    
    private func setupRemoteTransportControls() {
        print("🎮 Setting up remote controls...")
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            print("▶️ Remote play command received")
            self?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            print("⏸️ Remote pause command received")
            self?.pause()
            return .success
        }
        
        print("✅ Remote controls configured")
    }
    
    func loadAudio(named fileName: String, title: String? = nil, artworkName: String? = nil) {
        print("🔄 Loading audio file: \(fileName)")
        
        self.currentTitle = title
        self.currentArtwork = artworkName
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("❌ Could not find audio file: \(fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.prepareToPlay()
            print("✅ Successfully loaded audio: \(fileName)")
            updateNowPlayingInfo()
        } catch {
            print("❌ Error loading audio: \(error.localizedDescription)")
        }
    }
    
    func play() {
        print("▶️ Attempting to play audio...")
        audioPlayer?.play()
        isPlaying = true
        updateNowPlayingInfo()
        print("✅ Audio playing, now playing info updated")
    }
    
    func pause() {
        print("⏸️ Pausing audio...")
        audioPlayer?.pause()
        isPlaying = false
        updateNowPlayingInfo()
        print("✅ Audio paused, now playing info updated")
    }
    
    func updateNowPlayingInfo() {
        print("🔄 Updating now playing info...")
        guard let player = audioPlayer else {
            print("❌ Cannot update now playing info: No audio player available")
            return
        }
        
        var nowPlayingInfo = [String: Any]()
        
        // Add title
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentTitle ?? player.url?.lastPathComponent
        
        // Add duration and time
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Add artwork if available
        if let artworkName = currentArtwork {
            if let image = UIImage(named: artworkName) {
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                print("✅ Added artwork to now playing info")
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        print("✅ Now playing info updated with title: \(currentTitle ?? "unknown"), playback state: \(isPlaying ? "playing" : "paused")")
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
                play()
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