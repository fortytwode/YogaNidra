import SwiftUI

struct IWelcomeView: View {
    let nextPage: () -> Void
    
    var body: some View {
        ZStack {
            // Content
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
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
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity)
                        
                        // Value Proposition
                        VStack(spacing: 8) {
                            Text("Where ancient wisdom meets..")
                                .font(.system(size: 24, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Text("...your comfiest pajamas.")
                                .font(.system(size: 24, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.white)
                        .textShadowEffect()
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 10)
                        
                        // Benefits and Challenges
                        VStack(alignment: .leading, spacing: 30) {
                            // Benefits Section
                            VStack(alignment: .leading, spacing: 10) {
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
                            .cardBackgroundEffect()
                            
                            // Challenges Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Time to ditch:")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .textShadowEffect()
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("🤯 Midnight thought parties")
                                    Text("📱 The bedtime scroll")
                                    Text("😫 3am ceiling stares")
                                }
                                .font(.body)
                                .foregroundColor(.white)
                                .textShadowEffect()
                            }
                            .cardBackgroundEffect()
                        }
                    }
                    .padding(.horizontal, 24)
                }
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
                .padding(.horizontal, 16)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
        }
        .background {
            ZStack {
                // Background image
                Image("northern-lights")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.5),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

extension View {
    func textShadowEffect() -> some View {
        self.shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
    }
    
    func cardBackgroundEffect() -> some View {
        self.padding(16)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
    }
}

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
