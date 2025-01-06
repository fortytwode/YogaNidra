# Yoga Nidra App

A meditation app built with SwiftUI that offers guided Yoga Nidra sessions.

## Features
- [x] Session library with categorized meditations
- [x] Audio playback in foreground
- [x] Mini player for quick access
- [x] Session detail view
- [x] Progress tracking
- [ ] Background audio controls (In Progress)

## Current Technical Challenges

### Background Audio / Control Center Integration
Current Status: Not Working
- [x] Added background audio capability in Info.plist
- [x] Configured AVAudioSession for background playback
- [x] Implemented MPRemoteCommandCenter controls
- [x] Added MPNowPlayingInfoCenter updates
- [ ] Control Center controls not appearing when app is minimized

Attempted Solutions:
1. Basic AVAudioSession setup
   ```swift
   try session.setCategory(.playback)
   try session.setActive(true)
   ```

2. Enhanced AVAudioSession configuration
   ```swift
   try session.setCategory(
       .playback,
       mode: .default,
       options: [.mixWithOthers, .allowAirPlay]
   )
   ```

3. Added Now Playing Info updates
   ```swift
   MPNowPlayingInfoCenter.default().nowPlayingInfo = [
       MPMediaItemPropertyTitle: title,
       MPMediaItemPropertyPlaybackDuration: duration,
       MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime
   ]
   ```

4. Verified Info.plist configuration
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>audio</string>
   </array>
   ```

Next Steps to Try:
1. Verify background capability is properly enabled in Xcode project
2. Test on physical device (simulator might have limitations)
3. Add more detailed logging for audio session state
4. Investigate audio session activation timing

## Technical Details
- Swift and SwiftUI
- AVFoundation for audio playback
- MediaPlayer framework for system integration
- MVVM architecture
- Local data storage

### Data Models
- `YogaNidraSession`: Core session data structure
  - Title
  - Duration
  - Audio file reference
  - Thumbnail image reference
- `SessionCategory`: Enum defining all meditation categories

### Testing
- [ ] Unit tests for audio playback
- [ ] UI tests for main flows
- [ ] Performance testing
- [ ] User testing

## Setup
1. Clone the repository
2. Open `Yoga Nidra.xcodeproj`
3. Build and run

## Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Known Issues
- Background audio controls not appearing in Control Center
- Need to verify background mode capability in Xcode project settings