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
    private var isSeekInProgress = false
    
    var currentTime: TimeInterval {
        player?.currentTime().seconds ?? 0
    }
    
    var duration: TimeInterval {
        player?.currentItem?.duration.seconds ?? 0
    }
    
    private override init() {
        audioSession = AVAudioSession.sharedInstance()
        super.init()
        
        // Configure audio session immediately
        setupAudioSession()
        setupNotifications()
        
        // Begin observing interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )
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
            // Configure basic playback session
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowAirPlay]
            )
            
            // Activate the audio session
            try audioSession.setActive(true)
            
            print("✅ Audio Engine: Session configured for background playback")
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
        
        // Setup remote control events
        setupRemoteTransportControls()
    }
    
    private func setupRemoteTransportControls() {
        // Get the shared command center
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for play command
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        // Add handler for pause command
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        // Add handler for toggle play/pause command
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.player?.rate == 0 {
                self.play()
            } else {
                self.pause()
            }
            return .success
        }
        
        // Add handler for seek command
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task {
                await self.seek(to: event.positionTime)
            }
            return .success
        }
        
        // Enable skip commands
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            Task {
                await self.skipForward()
            }
            return .success
        }
        
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            Task {
                await self.skipBackward()
            }
            return .success
        }
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
            
            // Configure audio behavior for background playback
            player.automaticallyWaitsToMinimizeStalling = false
            player.allowsExternalPlayback = true
            
            // Enable background audio session if needed
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("❌ Audio Engine: Failed to activate session - \(error)")
            }
            
            // Observe player status
            statusObserver = playerItem.observe(\.status) { [weak self] item, _ in
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    self.updateNowPlayingInfo()  // Set initial now playing info
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
        player?.addPeriodicTimeObserver(forInterval: interval, queue: queue ?? .main) { [weak self] time in
            guard let self = self, !self.isSeekInProgress else { return }
            block(time)
        }
    }
    
    private func updateNowPlayingInfo(title: String? = nil, artist: String? = nil) {
        var nowPlayingInfo = [String: Any]()
        
        // Add media info
        nowPlayingInfo[MPMediaItemPropertyTitle] = title ?? "Sleep Meditation"
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist ?? "Yoga Nidra"
        
        // Add playback info
        if let player = player {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        }
        
        // Update the now playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func play() {
        player?.play()
        updateNowPlayingInfo()
    }
    
    func pause() {
        player?.pause()
        updateNowPlayingInfo()
    }
    
    func seek(to time: TimeInterval) async {
        isSeekInProgress = true
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        await player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        isSeekInProgress = false
    }
    
    func skipForward(by seconds: TimeInterval = 15) async {
        let newTime = min(currentTime + seconds, duration)
        await seek(to: newTime)
    }
    
    func skipBackward(by seconds: TimeInterval = 15) async {
        let newTime = max(currentTime - seconds, 0)
        await seek(to: newTime)
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
