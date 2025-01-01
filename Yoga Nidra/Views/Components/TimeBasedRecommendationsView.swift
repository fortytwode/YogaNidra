import SwiftUI

struct TimeBasedRecommendationsView: View {
    let sessions: [YogaNidraSession]
    
    private var timeBasedSession: YogaNidraSession? {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<5: // Late night (12 AM - 5 AM)
            return sessions.first { $0.category == .nightAnxiety }
        case 5..<9: // Early morning (5 AM - 9 AM)
            return sessions.first { $0.category == .sleepRestoration }
        case 9..<21: // Day time (9 AM - 9 PM)
            return sessions.first { $0.category == .quickSleep } // For power naps
        case 21..<24: // Evening (9 PM - 12 AM)
            return sessions.first { $0.category == .deepSleep }
        default:
            return sessions.first
        }
    }
    
    private var timeBasedMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<5:
            return "Can't sleep? Try this:"
        case 5..<9:
            return "Start your day refreshed:"
        case 9..<15:
            return "Perfect for a power nap:"
        case 15..<21:
            return "Afternoon recharge:"
        case 21..<24:
            return "Prepare for deep sleep:"
        default:
            return "Recommended for you:"
        }
    }
    
    var body: some View {
        if let session = timeBasedSession {
            VStack(alignment: .leading, spacing: 16) {
                Text(timeBasedMessage)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: SessionDetailView(session: session)) {
                    HStack(spacing: 16) {
                        Image(systemName: session.category.icon)
                            .font(.title)
                            .foregroundColor(session.category.color)
                            .frame(width: 44, height: 44)
                            .background(session.category.color.opacity(0.2))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.headline)
                            
                            HStack {
                                Text(session.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(session.category.color)
                                
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                Text(formatDuration(session.duration))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
} 