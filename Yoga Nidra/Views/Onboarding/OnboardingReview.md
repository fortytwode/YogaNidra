# Yoga Nidra - Onboarding Flow Review

## Overview
The onboarding process is designed to understand user's sleep patterns, challenges, and preferences while educating them about Yoga Nidra's benefits. The flow concludes with a personalized sleep profile and a trial offer.

## Screen Flow
1. **WelcomeView**
   - Initial welcome screen
   - CTA: "Start your journey →"
   - Background: Calming nature scene

2. **BenefitsView**
   - Detailed explanation of Yoga Nidra practice
   - CTA: "Continue →"
   - Focus on educational content
   - Understanding the practice basics

3. **ExplanationView**
   - Highlights key benefits of Yoga Nidra
   - Fair trial policy explanation
   - Comparison with daily habits
   - Scientific benefits presentation

4. **GoalsView**
   - "What brings you here?"
   - Multiple choice selection
   - Goals like Better Sleep, Stress Reduction, etc.
   - Personalizes user journey

5. **SleepQualityView**
   - Assesses user's current sleep quality
   - Interactive rating system
   - Captures baseline sleep metrics

6. **SleepPatternView**
   - Captures typical sleep duration
   - Time range selection
   - Sleep schedule understanding

7. **FallAsleepView**
   - Time to fall asleep assessment
   - Duration options (15min to 60min+)
   - Initial sleep difficulty measure

8. **SleepScienceView**
   - Educational content about sleep science
   - Connection between Yoga Nidra and sleep quality
   - Scientific backing for the practice
   - Explains why falling asleep can be challenging

9. **WakeUpView**
   - Night waking frequency
   - Sleep continuity assessment
   - Sleep cycle education

10. **MorningTirednessView**
    - Morning energy assessment
    - Wake-up quality measurement
    - Morning mood tracking

11. **SleepFeelingsView**
    - Emotional aspects of sleep
    - Sleep anxiety assessment
    - Mental state during bedtime

12. **RelaxationObstaclesView**
    - Identifies barriers to relaxation
    - Common sleep obstacles
    - Personalization factors

13. **SleepImpactView**
    - How sleep affects daily life
    - Impact assessment
    - Quality of life factors

14. **FinalProfileView**
    - Displays personalized sleep profile
    - Shows radar chart of sleep metrics
    - CTA: "Next step →"

15. **PaywallView**
    - Trial offer presentation
    - Background: mountain-lake-twilight image with gradient
    - Primary CTA: "Start free trial"
    - Secondary: "Restore purchases"
    - Skip option (X button)

## Technical Implementation
- Uses SwiftUI for modern, fluid UI
- TabView with .page style for smooth transitions
- Background images with gradients for visual appeal
- Consistent navigation pattern with next/back functionality
- State management through OnboardingManager
- In-app purchase handling via StoreManager

## Data Collection
- Sleep quality metrics
- Schedule preferences
- Emotional factors
- Obstacles and challenges
- Impact assessment
- Goal setting
- Morning energy levels
- Sleep initiation time
- Night waking frequency

## User Experience
- Progressive disclosure of information
- Educational content mixed with data collection
- Visual feedback and engagement
- Clear call-to-actions
- Easy navigation
- Option to skip trial
- Comprehensive sleep assessment

## Integration Points
- OnboardingManager for flow control
- StoreManager for trial/purchase handling
- UserPreferences for data storage
- Analytics for user journey tracking

## Future Considerations
- A/B testing of CTAs
- Localization support
- Accessibility improvements
- Additional personalization options
- Enhanced analytics tracking
- Question branching based on responses
- Dynamic content based on user goals