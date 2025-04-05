import SwiftUI

struct GoalsView: View {
    let nextPage: () -> Void
    @State private var selectedGoals: Set<String> = []
    
    private let goals = [
        "🏋️ Optimize fitness",
        "🌙 Solve sleep disorder",
        "😌 Reduce anxiety",
        "🌅 Become a morning person/early riser",
        "⚙️ Optimize productivity"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Introduction text
            VStack(spacing: 16) {
                Text("First, let's get to know you better!")
                    .font(.body)
                    .foregroundColor(.white)
                
                Text("What brings you to Yoga Nidra today?")
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
                
                Text("Quick quiz allows us to personalize the app for you (faster than counting sheep) 💫")
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
