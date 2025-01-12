import SwiftUI

struct WelcomeView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            // Hero Image
            Image("Onboarding/welcome-hero")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            
            // Header
            Text("Welcome to Yoga Nidra")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Subheader
            VStack(spacing: 8) {
                Text("Restore yourself tonight...")
                    .font(.system(size: 28, weight: .medium))
                Text("...to win the day tomorrow.")
                    .font(.system(size: 28, weight: .medium))
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            
            // Benefits and Pain Points
            VStack(alignment: .leading, spacing: 24) {
                Text("😴 Experience deep restorative sleep.")
                    .font(.title3)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("❌ Say goodbye to:")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Spacer().frame(width: 24)  // 3 space offset
                            Label("Restless nights", systemImage: "moon.zzz.fill")
                        }
                        HStack {
                            Spacer().frame(width: 24)  // 3 space offset
                            Label("Sleepless hours", systemImage: "clock.fill")
                        }
                        HStack {
                            Spacer().frame(width: 24)  // 3 space offset
                            Label("Racing thoughts", systemImage: "brain.head.profile")
                        }
                    }
                    .font(.body)
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: nextPage) {
                Text("Let's go")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.black)
    }
}

#Preview {
    WelcomeView(nextPage: {})
        .preferredColorScheme(.dark)
} 