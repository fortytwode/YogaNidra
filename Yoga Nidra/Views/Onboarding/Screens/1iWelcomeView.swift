import SwiftUI

struct IWelcomeView: View {
    let nextPage: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Image("northern-lights")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) {
                        // Title
                        VStack(spacing: 4) {
                            Text("Welcome to")
                                .font(.system(size: 36, weight: .bold))
                            Text("Yoga Nidra ✨")
                                .font(.system(size: 36, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .textShadowEffect()
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity)
                        
                        // Value Proposition
                        VStack(spacing: 8) {
                            Text("Where ancient wisdom meets...")
                                .font(.system(size: 18, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Text("...your comfiest pajamas.")
                                .font(.system(size: 18, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.white)
                        .textShadowEffect()
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Benefits and Challenges
                        VStack(alignment: .leading, spacing: 32) {
                            // Benefits Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Here's the goodness:")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .textShadowEffect()
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("✨ A spa day for your thoughts")
                                    Text("🌙 20 mins = 2 hours of deep rest")
                                    Text("💫 Wake up actually feeling refreshed")
                                }
                                .font(.body)
                                .foregroundColor(.white)
                                .textShadowEffect()
                            }
                            
                            // Challenges Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Time to ditch:")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .textShadowEffect()
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("😴 Those midnight thought parties")
                                    Text("🌑 The endless bedtime scroll")
                                    Text("💤 The 3am ceiling stare")
                                }
                                .font(.body)
                                .foregroundColor(.white)
                                .textShadowEffect()
                            }
                        }
                        
                        Spacer()
                            .frame(height: 30)
                        
                        // CTA Button
                        Button(action: nextPage) {
                            Text("Begin Your Journey →")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, 16)
            }
            .ignoresSafeArea()
        }
    }
}

extension View {
    func textShadowEffect() -> some View {
        self.shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)
    }
}

// Custom label style for emoji + text
struct EmojiLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            configuration.icon
                .font(.body)
            configuration.title
                .font(.body)
        }
    }
}

#Preview {
    IWelcomeView(nextPage: {})
        .preferredColorScheme(.dark)
}
