import SwiftUI

struct BenefitsView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("✨ Fair Trial Policy")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Yoga Nidra is free for\nyou to try")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("If you like it - we depend on your support to pay our sleep experts and meditation guides")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 40)
            
            // Comparison Box
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("🌙")
                    Text("Your sleep...")
                }
                .padding()
                .background(Color(white: 0.2))
                .cornerRadius(12)
                
                Text("VS")
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    Text("☕️")
                    Text("Daily coffee...")
                }
                .padding()
                .background(Color(white: 0.2))
                .cornerRadius(12)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            
            // Benefits Box
            VStack(alignment: .leading, spacing: 20) {
                Text("Yoga Nidra helps you sleep better and live longer...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 16) {
                    benefitRow(emoji: "📊", text: "Proven to reduce stress by 44%")
                    benefitRow(emoji: "⏰", text: "Cuts the time to fall asleep by up to 37%")
                    benefitRow(emoji: "✨", text: "20 minutes of Yoga Nidra can provide restorative benefits similar to 2-3 hours...")
                }
            }
            .padding(20)
            .background(Color(white: 0.1))
            .cornerRadius(16)
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: nextPage) {
                Text("That's fair!")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.5, green: 0.4, blue: 1.0))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func benefitRow(emoji: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.title2)
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    BenefitsView(nextPage: {})
} 
    
    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

