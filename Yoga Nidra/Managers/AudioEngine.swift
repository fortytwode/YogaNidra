import AVFoundation
import MediaPlayer
import Combine
import UIKit

@MainActor
final class AudioEngine: NSObject {
    static let shared = AudioEngine()
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var itemObserver: NSKeyValueObservation?
    private var audioSession: AVAudioSession
    private var isSeekInProgress: Bool = false
    private var currentPlayingSession: YogaNidraSession?
    
    var currentTime: TimeInterval {
        player?.currentTime().seconds ?? 0
    }
    
    var duration: TimeInterval {
        player?.currentItem?.duration.seconds ?? 0
    }
    
    private override init() {
        audioSession = AVAudioSession.sharedInstance()
        super.init()
        
        // Configure audio session first
        setupAudioSession()
        
        // Then setup remote controls and notifications
        setupRemoteCommandCenter()
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
            // Configure audio session for background playback
            let session = AVAudioSession.sharedInstance()
            
            // Configure the audio session category and mode with options
            try session.setCategory(.playback, 
                                  mode: .spokenAudio,
                                  options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .duckOthers])
            
            // Set active with options
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
            
            print("✅ Audio Engine: Session configured for background playback")
        } catch {
            print("❌ Audio Engine: Failed to configure session - \(error)")
        }
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("✅ Audio Engine: Session deactivated")
        } catch {
            print("❌ Audio Engine: Failed to deactivate session - \(error)")
        }
    }
    
    private func ensureAudioSessionActive() {
        do {
            let session = AVAudioSession.sharedInstance()
            if !session.isOtherAudioPlaying {
                try session.setActive(true, options: .notifyOthersOnDeactivation)
            }
        } catch {
            print("❌ Audio Engine: Failed to activate session - \(error)")
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
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play Command
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.play()
            return .success
        }
        
        // Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.pause()
            return .success
        }
        
        // Skip Forward
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            let newTime = min(self.currentTime + 30, self.duration)
            self.seek(to: newTime)
            return .success
        }
        
        // Skip Backward
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            let newTime = max(self.currentTime - 15, 0)
            self.seek(to: newTime)
            return .success
        }
        
        // Enable seeking
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: event.positionTime)
            return .success
        }
    }
    
    private func setupNowPlaying(title: String? = nil, artist: String? = nil) {
        var nowPlayingInfo = [String: Any]()
        
        // Add metadata
        nowPlayingInfo[MPMediaItemPropertyTitle] = title ?? "Sleep Meditation"
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist ?? "Yoga Nidra"
        
        // Add playback info
        if let player = player {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        }
        
        // Add artwork if available
        if let image = UIImage(named: "AppIcon") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlayingInfo() {
        // Remove this method as it's now handled by AudioManager
    }
    
    private func setupNowPlaying() {
        // Configure audio session again when starting playback
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, 
                                  mode: .spokenAudio,
                                  options: [.allowAirPlay, .allowBluetooth])
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            print("❌ Audio Engine: Failed to configure session during playback - \(error)")
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
            
            // Configure audio session again to ensure it's active
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
                    self.setupNowPlaying()
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
            
            // Add periodic time observer
            let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                // Removed updateNowPlayingInfo call
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
    
    func play() {
        do {
            // Ensure audio session is active before playing
            ensureAudioSessionActive()
            player?.play()
            
            // Set audio session active again after starting playback
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Audio Engine: Failed to activate session for playback - \(error)")
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to time: TimeInterval) {
        isSeekInProgress = true
        let cmTime = CMTime(seconds: time, preferredTimescale: 1)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
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
    
    func play(_ session: YogaNidraSession) async {
        do {
            // Configure audio session for playback
            setupAudioSession()
            
            // Load audio URL
            guard let url = Bundle.main.url(forResource: session.audioFileName, withExtension: "mp3") else {
                print("❌ Audio Engine: Could not find audio file: \(session.audioFileName)")
                return
            }
            
            // Create player item
            let playerItem = AVPlayerItem(url: url)
            
            // Replace current item
            if player == nil {
                player = AVPlayer(playerItem: playerItem)
            } else {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            // Start playback
            player?.play()
            
            // Add delay before setting current session to allow sheet animation
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            currentPlayingSession = session
            
            print("✅ Audio Engine: Started playback of \(session.title)")
        } catch {
            print("❌ Audio Engine: Failed to play - \(error)")
        }
    }
}
