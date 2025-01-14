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
            Spacer()
            
            // Introduction text
            VStack(spacing: 16) {
                Text("Let's find out your sleep profile with this quick quiz.")
                    .font(.body)
                    .foregroundColor(.white)
                
                Text("What brings you here?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 20)
            
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
                
                Text("This allows us to make a custom-tailored experience for you")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("(takes < 2 mins)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(
            ZStack {
                Image("mountain-lake-twilight")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
    }
}