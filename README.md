# Yoga Nidra App

session card alignment fixed
added favorites



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
- `PreferencesManager.swift` - Handles user preferences and onboarding data persistence
- `AudioManager.swift` - Controls meditation audio playback and background audio
- `DownloadManager.swift` - Manages offline session downloads
- `SubscriptionManager.swift` - Handles in-app purchases and subscription status

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


## Project Structure

### Core Views
- `ContentView.swift` - Root view with tab navigation and onboarding management
- `HomeView.swift` - Main dashboard with featured sessions and recommendations
- `LibraryView.swift` - Browse and search all meditation sessions
- `ProgressTabView.swift` - User's meditation progress and statistics

### Onboarding Flow
- `OnboardingContainerView.swift` - Container managing the onboarding flow and navigation
- `WelcomeView.swift` - Initial welcome screen
- `BenefitsView.swift` - Explains app benefits and fair trial policy
- `SleepScienceView.swift` - Presents research-backed benefits of Yoga Nidra
- `GoalsView.swift` - Captures user's primary sleep and wellness goals
- `SleepQualityView.swift` - Assesses user's current sleep satisfaction
- `SleepPatternView.swift` - Captures typical sleep duration
- `FallAsleepView.swift` - Assesses time taken to fall asleep
- `WakeUpView.swift` - Captures frequency of night wakings
- `MorningTirednessView.swift` - Assesses morning energy levels
- `SleepFeelingsView.swift` - Captures emotional relationship with sleep
- `FinalProfileView.swift` - Shows personalized sleep analysis and subscription options

### Components
- `RadarChart.swift` - Visualization for sleep profile metrics
- `QuestionScreenView.swift` - Reusable template for onboarding questions

### Managers
- `PreferencesManager.swift` - Handles user preferences and onboarding data persistence
- `AudioManager.swift` - Controls meditation audio playback and background audio
- `DownloadManager.swift` - Manages offline session downloads
- `SubscriptionManager.swift` - Handles in-app purchases and subscription status

### Models
- `UserPreferences.swift` - Data model for user's sleep preferences and profile
- `Session.swift` - Model for meditation sessions (duration, category, audio)
- `QuestionOption.swift` - Model for onboarding question options
- `SleepMetric.swift` - Model for radar chart metrics
- `TabBarState.swift` - Manages tab bar visibility and height

### Utilities
- `TabBarHeightPreferenceKey.swift` - SwiftUI preference key for dynamic tab bar sizing
- `Color+Extensions.swift` - Color utility extensions
- `View+Extensions.swift` - View modifier extensions
- `Date+Extensions.swift` - Date formatting utilities

### Modifiers
- `DarkModeModifier.swift` - Consistent dark mode styling (to be removed)
- `SafeAreaModifier.swift` - Custom safe area handling

### Detailed View Components

#### Home Tab Components
- `FeaturedSessionCard.swift` - Large card showing featured meditation session
- `SessionRowView.swift` - Reusable row for session lists
- `CategoryGridView.swift` - Grid layout for session categories
- `RecommendedSection.swift` - Personalized session recommendations
- `SessionProgressBar.swift` - Shows meditation session progress

#### Library Tab Components
- `SessionListView_v2.swift` - Enhanced session browsing with filters
- `CategoryFilterView.swift` - Filter sessions by category
- `DurationFilterView.swift` - Filter sessions by duration
- `SearchBarView.swift` - Custom search implementation
- `DownloadStatusView.swift` - Shows download progress/status

#### Progress Tab Components
- `StatisticsView.swift` - Shows meditation statistics
- `StreakView.swift` - Displays user's meditation streak
- `CalendarView.swift` - Monthly meditation calendar
- `AchievementsView.swift` - User's meditation milestones
- `ProgressChartView.swift` - Visualizes meditation progress

#### Common UI Components
- `CustomButton.swift` - Reusable button styles
- `LoadingView.swift` - Loading state animations
- `ErrorView.swift` - Error state handling
- `EmptyStateView.swift` - Empty state placeholders
- `GradientBackground.swift` - Custom gradient backgrounds

### Architecture & Design Patterns

#### MVVM Architecture
- **Views**: SwiftUI views for UI representation
- **ViewModels**: Business logic and state management
- **Models**: Data structures and business models
- **Services**: Network, persistence, and system services

#### Key Design Patterns
- **Singleton**: Used for managers (PreferencesManager, AudioManager)
- **Observer**: Using Combine for reactive updates
- **Dependency Injection**: For testing and modularity
- **Repository**: Data access abstraction

### Development Setup

#### Requirements
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

#### Installation
1. Clone the repository
2. Open `Yoga Nidra.xcodeproj`
3. Install dependencies (if using CocoaPods/SPM)
4. Build and run

#### Configuration
- Add required keys to `Config.xcconfig`
- Set up development team in project settings
- Configure StoreKit for in-app purchases

### Testing
- **Unit Tests**: Business logic and model testing
- **UI Tests**: Key user flows
- **Integration Tests**: API and persistence testing

### Dependencies
- **AVFoundation**: Audio playback
- **StoreKit**: In-app purchases
- **UserDefaults**: Local data persistence
- **Combine**: Reactive programming

