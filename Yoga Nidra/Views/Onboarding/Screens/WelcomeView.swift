import SwiftUI

struct WelcomeView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            // Title
            VStack(spacing: 8) {
                Text("Welcome to Yoga Nidra")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Wake up rejuvenated. Every day.")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            // Description
            Text("Experience deep restorative sleep like never before.\nSay goodbye to restless nights, sleepless hours, and racing thoughts.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: nextPage) {
                Text("Find out how")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    WelcomeView(nextPage: {})
        .preferredColorScheme(.dark)
} 