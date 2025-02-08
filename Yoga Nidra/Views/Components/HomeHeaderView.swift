import SwiftUI

struct HomeHeaderView: View {
    @State private var isAnimating = false
    @State private var parallaxOffset: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Header
            Text("Yoga Nidra")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            // Banner Card
            GeometryReader { geometry in
                ZStack {
                    // Background Gradient with soft glow
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.customIndigo,
                            Color.customPurple
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .blur(radius: 1)
                    )
                    
                    // Subtle stars background
                    StarsView()
                        .opacity(0.3)
                        .offset(y: isAnimating ? 2 : 0)
                        .animation(
                            Animation.easeInOut(duration: 3.0)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Time to Unwind")
                                    .headerTitle()
                                    .offset(x: parallaxOffset * -5)
                                
                                Text("Let your mind drift into peaceful dreams")
                                    .headerSubtitle()
                                    .offset(x: parallaxOffset * -3)
                            }
                            
                            Spacer()
                            
                            // Moon Icon with animation
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                                .offset(y: isAnimating ? -5 : 0)
                                .offset(x: parallaxOffset * 5)
                                .animation(
                                    Animation.easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                                .shadow(color: .white.opacity(0.3), radius: 5)
                        }
                    }
                    .padding(24)
                }
                .cornerRadius(16)
                .shadow(color: Color.customPurple.opacity(0.3), radius: 10)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let translation = value.translation.width
                            parallaxOffset = translation / geometry.size.width
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                parallaxOffset = 0
                            }
                        }
                )
            }
            .frame(height: 160)
            .padding(.horizontal, 16)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// Stars background view
private struct StarsView: View {
    var body: some View {
        ZStack {
            ForEach(0..<15) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .offset(
                        x: CGFloat.random(in: -100...100),
                        y: CGFloat.random(in: -50...50)
                    )
            }
        }
    }
}

// Modifiers for reusable styles
extension View {
    func headerTitle() -> some View {
        self.font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
    }
    
    func headerSubtitle() -> some View {
        self.font(.system(size: 17))
            .foregroundColor(.white.opacity(0.9))
    }
}

// Color Extension for theme colors
extension Color {
    static let customPurple = Color(red: 0.29, green: 0.0, blue: 0.51)
    static let customIndigo = Color(red: 0.24, green: 0.24, blue: 0.76)
}
