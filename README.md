# Yoga Nidra App

A meditation app built with SwiftUI that offers guided Yoga Nidra sessions.

## Features
- [x] Session library with categorized meditations
- [x] Audio playback in foreground
- [x] Mini player for quick access
- [x] Session detail view
- [x] Progress tracking
- [x] Background audio controls ✨
  - Control Center integration
  - Lock screen controls
  - Background playback

## Technical Notes

### Background Audio / Control Center Integration
Status: ✅ Working
- Successfully implemented on physical devices
- Shows audio controls in Control Center
- Allows background playback
- Responds to system audio controls

Note: Control Center integration has limited functionality in iOS Simulator:
- Control Center controls may not appear in simulator
- For full testing, use physical iOS devices
- This is expected behavior due to simulator limitations


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

## Immediate Next Steps
1. Content Preparation
   - [x] Basic audio player functionality
   - [ ] Finalize meditation audio templates
   - [ ] Record initial free sessions
   - [ ] Record premium sessions

2. Monetization Setup
   - [ ] Basic in-app purchase setup
   - [ ] Premium content flags
   - [ ] Purchase restoration
   - [ ] Receipt validation

3. User Experience
   - [ ] First-time user onboarding
   - [ ] Session recommendation flow
   - [ ] Free vs Premium content indicators
   - [ ] "Upgrade to Premium" prompts

4. Analytics & Tracking
   - [ ] Basic analytics integration
   - [ ] Track key user actions
   - [ ] Monitor conversion points

**
# Project Structure

## Core Files
### App
- `YogaNidraApp.swift` - Main app entry point, sets up environment objects
- `ContentView.swift` - Main container view with tab navigation

### Models
- `YogaNidraSession.swift` - Data model for meditation sessions
- `SessionCategory.swift` - Enum for session categories
- `PlayerState.swift` - Manages global audio playback state

### Views
#### Main Views
- `HomeView.swift` - Home tab with featured sessions
- `LibraryView.swift` - Browse all meditation sessions
- `ProgressView.swift` - User's meditation progress

#### Components
- `SessionCardView.swift` - Reusable session card component
- `AudioPlayerView.swift` - Audio controls and progress
- `MiniPlayerView.swift` - Minimized player for continuous playback
- `SessionDetailView.swift` - Detailed view of a session

### Managers
- `AudioManager.swift` - Handles audio playback and background audio
- `ProgressManager.swift` - Tracks user's meditation progress

### Data
- `sessions.csv` - Source data for meditation sessions
- `PreviewData.swift` - Sample data for SwiftUI previews

### Resources
- `/Audio` - Contains meditation audio files
- `/Images` - Session thumbnails and app assets
- `Yoga-Nidra-Info.plist` - App configuration and permissions

### Supporting Files
- `Assets.xcassets` - Image assets and app icons
- `Preview Content` - Development-time preview resources

