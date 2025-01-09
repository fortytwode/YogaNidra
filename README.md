# Yoga Nidra App

todo:
- [ ] check subs purchase flow.
- [ ] update onboarding and refine it. 
- [ ] upload session audios.
- [ ] Refine onboarding flow
- [ ] Add benefits/value proposition screens


- [ ] Set up custom paywall design
- [ ] Test purchase flow end-to-end
- [ ] Verify trial period activation
- [ ] Test restore purchases
- [ ] Add subscription benefits screen in onboarding
- [ ] Test subscription status persistence
- [ ] Add subscription analytics/tracking

- [ ] Upload all session audio files
- [ ] Verify audio quality
- [ ] Test background playback
- [ ] Test offline downloads
- [ ] Verify premium content flagging

- [ ] Add proper error handling throughout app
- [ ] Implement crash reporting
- [ ] Add analytics for key user actions
- [ ] Test network connectivity handling
- [ ] Add loading states for async operations
- [ ] Test deep linking
- [ ] Verify app size optimization
- [ ] Add proper App Store metadata

**
A meditation app built with SwiftUI that offers guided Yoga Nidra sessions.

## Implemented Features ✅
- [x] Session library with categorized meditations
- [x] Audio playback in foreground and background
- [x] Mini player for quick access
- [x] Session detail view
- [x] Progress tracking
- [x] Background audio controls
  [x] Control Center integration
  [x] Lock screen controls
  [x] Background playback
- [x] Personalized recommendations
- [x] Comprehensive onboarding

- [x] Premium subscription integration
  - Trial period
  - Purchase handling
  - Premium content flagging
- [x] Offline mode
  - Download management
  - Progress tracking
  - Network status detection
- [x] User preferences & personalization

## Technical Notes

### Background Audio / Control Center Integration
Status: ✅ Working
- Successfully implemented on physical devices
- Shows audio controls in Control Center
- Allows background playback
- Responds to system audio controls

### Offline Support
Status: ✅ Working
- Download management for premium users
- Progress tracking for downloads
- Network status monitoring
- Persistent storage of downloaded content

### Premium Features
Status: ✅ Working
- Trial period implementation
- Subscription management
- Premium content access control
- Restore purchases functionality

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


## Setup
1. Clone the repository
2. Open `Yoga Nidra.xcodeproj`
3. Build and run

## Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+


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

# Additional Features & Architecture

## Features Added
- Personalized meditation recommendations based on sleep patterns
- Comprehensive onboarding flow with sleep assessment
- Premium content with subscription
- User preference tracking
- Personalized dashboard

## Architecture Components Added

### Views
- `ContentView`: Main tab-based navigation
- `HomeView`: Personalized dashboard with recommendations
- `OnboardingContainerView`: Multi-step onboarding process
- `FinalProfileView`: Subscription and personalization summary

### Managers
- `PreferencesManager`: Handles user preferences and personalization
- `OnboardingManager`: Controls onboarding flow
- `SubscriptionManager`: Handles premium features and trials

### Models
- `Session`: Meditation session data structure
- `UserPreferences`: User settings and sleep preferences
- `QuestionOption`: Onboarding question structure

## Setup & Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

