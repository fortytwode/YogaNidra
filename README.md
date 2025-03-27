# Yoga Nidra App
2.1

push custom diaglog
superwall sdk
fb sdk

**
1.3

progress tab
  recent activity calcs
  Streak card
  session times

Onboarding with sass	1.2	done
Firebase to track progress	1.2	done
Firebase basic analytics	1.2	done
rating prompt	1.2	done
download for offline use	1.4	done
add background play, lock screen	1.4	done
Screenshots with sass	1.4	done
separate download section	1.4	done
Deep linking	1.8	done
Valentine's day event	1.8	done


1.2 Feb 9th

- added missing image - energy renewal
- updated screenshots
- made categories dynamic rather than hardcoded
- uploaded session audios to Firebase Storage
- set up firebase analytics
  - subscription metrics
  - progress metrics on progress tab
- firebase app check to do
- fix sleep science view
- enabled background audio playback
- control center integration
- download and play offline

1.1 -> Feb 2. 

- added ratings prompts.
- added favorites.
- added recent meditations.
- added session card alignment.
- added a ton of new meditations

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
- [x] Custom paywall design
- [x] Purchase flow end-to-end
- [x] Trial period activation
- [x] Restore purchases
- [x] Subscription benefits screen in onboarding
- [x] Subscription status persistence
- [x] Subscription analytics/tracking
- [x] Proper error handling throughout app
- [x] Analytics for key user actions
- [x] Network connectivity handling
- [x] Loading states for async operations
- [x] Deep linking
- [x] App size optimization

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

