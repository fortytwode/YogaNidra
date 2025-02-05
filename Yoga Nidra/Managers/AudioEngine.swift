import AVFoundation
import MediaPlayer
import Combine

@MainActor
final class AudioEngine: NSObject {
    static let shared = AudioEngine()
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var itemObserver: NSKeyValueObservation?
    private var audioSession: AVAudioSession
    
    var currentTime: TimeInterval {
        player?.currentTime().seconds ?? 0
    }
    
    var duration: TimeInterval {
        player?.currentItem?.duration.seconds ?? 0
    }
    
    private override init() {
        audioSession = AVAudioSession.sharedInstance()
        super.init()
        Task { @MainActor in
            setupAudioSession()
            setupNotifications()
        }
    }
    
    deinit {
        Task { @MainActor in
            // Clean up observers and player
            if let timeObserver = timeObserver {
                removeTimeObserver(timeObserver)
                self.timeObserver = nil
            }
            statusObserver?.invalidate()
            itemObserver?.invalidate()
            NotificationCenter.default.removeObserver(self)
            
            // Clean up audio session
            deactivateAudioSession()
        }
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, policy: .longFormAudio, options: [.allowAirPlay, .allowBluetoothA2DP])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio Engine: Session configured")
        } catch {
            print("❌ Audio Engine: Failed to configure session - \(error)")
        }
    }
    
    private func deactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            print("✅ Audio Engine: Session deactivated")
        } catch {
            print("❌ Audio Engine: Failed to deactivate session - \(error)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: audioSession
        )
    }
    
    func prepareForPlayback(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        Task { @MainActor in
            // Remove existing observers and player
            if let timeObserver = timeObserver {
                removeTimeObserver(timeObserver)
                self.timeObserver = nil
            }
            statusObserver?.invalidate()
            itemObserver?.invalidate()
            
            // Create new AVPlayer
            let playerItem = AVPlayerItem(url: url)
            if player == nil {
                player = AVPlayer(playerItem: playerItem)
            } else {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            guard let player = player else {
                completion(.failure(NSError(domain: "AudioEngine", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create player"])))
                return
            }
            
            // Configure audio behavior
            player.automaticallyWaitsToMinimizeStalling = false
            player.allowsExternalPlayback = true
            
            // Observe player status
            statusObserver = playerItem.observe(\.status) { [weak self] item, _ in
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    completion(.success(()))
                case .failed:
                    completion(.failure(item.error ?? NSError(domain: "AudioEngine", code: -1)))
                default:
                    break
                }
            }
            
            // Observe current item
            itemObserver = player.observe(\.currentItem) { [weak self] player, _ in
                Task { @MainActor [weak self] in
                    if player.currentItem == nil {
                        if let timeObserver = self?.timeObserver {
                            self?.removeTimeObserver(timeObserver)
                            self?.timeObserver = nil
                        }
                    }
                }
            }
        }
    }
    
    func removeTimeObserver(_ observer: Any?) {
        guard let observer = observer else { return }
        player?.removeTimeObserver(observer)
    }
    
    @discardableResult
    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue?, using block: @escaping (CMTime) -> Void) -> Any? {
        player?.addPeriodicTimeObserver(forInterval: interval, queue: queue ?? .main, using: block)
    }
    
    func play() {
        player?.play()
        setupNowPlaying()
    }
    
    func pause() {
        player?.pause()
        updateNowPlaying()
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
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
    
    private func setupNowPlaying() {
        var nowPlayingInfo = [String: Any]()
        
        if let player = player {
            nowPlayingInfo[MPMediaItemPropertyTitle] = "Sleep Meditation"
            nowPlayingInfo[MPMediaItemPropertyArtist] = "Yoga Nidra"
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlaying() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        
        if let player = player {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
