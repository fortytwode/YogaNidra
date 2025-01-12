import SwiftUI

struct GoalsView: View {
    let nextPage: () -> Void
    @State private var selectedGoals: Set<String> = []
    
    private let goals = [
        "😴 Better Sleep Quality",
        "😌 Stress Reduction",
        "🧘‍♀️ Deep Relaxation",
        "🎯 Focus Enhancement",
        "⚡️ Energy Improvement"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Introduction text
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Let's find out your sleep profile with this quick quiz.")
                        .font(.body)
                        .foregroundColor(.white)
                    Text("...so we can personalize your journey.")
                        .font(.body)
                        .foregroundColor(.white)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                
                Text("What brings you here?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            // Goals selection
            VStack(spacing: 16) {
                ForEach(goals, id: \.self) { goal in
                    Button {
                        selectedGoals.insert(goal)
                        // Automatically advance after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            nextPage()
                        }
                    } label: {
                        HStack {
                            Text(goal)
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color(white: 0.2))
                        .cornerRadius(12)
                    }
                }
                
                Text("(takes < 2 mins)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
} 