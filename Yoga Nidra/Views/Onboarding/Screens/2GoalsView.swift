import SwiftUI

struct GoalsView: View {
    let nextPage: () -> Void
    @State private var selectedGoals: Set<String> = []
    
    private let goals = [
        "😴 Sweet dreams & better sleep",
        "😌 A calmer mind at rest",
        "🧘‍♀️ Deep peaceful relaxation",
        "✨ Mental clarity & focus",
        "🌙 Wake up feeling refreshed"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Introduction text
            VStack(spacing: 16) {
                Text("First, let's get to know you better!")
                    .font(.body)
                    .foregroundColor(.white)
                
                Text("What would you love to improve about your sleep?")
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
                
                Text("Quick quiz (faster than counting sheep) 💫")
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

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView(nextPage: {})
            .preferredColorScheme(.dark)
    }
}
