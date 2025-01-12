import SwiftUI

struct BenefitsView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Fair Trial Badge
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.yellow)
                Text("Fair Trial Policy")
                    .font(.headline)
            }
            
            // Main Message
            Text("Yoga Nidra is free for you to try")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("If you like it - we depend on your support to pay our sleep experts and meditation guides")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Value Comparison Card
            HStack(spacing: 0) {
                // Left side
                VStack(alignment: .leading) {
                    Text("Your sleep health")
                        .font(.headline)
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(12)
                }
                .frame(maxWidth: .infinity)
                
                Text("VS")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Right side
                VStack(alignment: .trailing) {
                    Text("Daily coffee")
                        .font(.headline)
                        .padding()
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(12)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(24)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(16)
            
            // Benefits List
            VStack(alignment: .leading, spacing: 16) {
                Text("Yoga Nidra helps you live longer and happier.")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    benefitBullet("Proven to reduce stress by 44% after a single session")
                    benefitBullet("Cuts the time to fall asleep by up to 37%")
                    benefitBullet("20 minutes of Yoga Nidra can provide restorative benefits similar to 2-3 hours of sleep")
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(16)
            
            Spacer()
            
            // Continue Button
            Button(action: nextPage) {
                Text("That's fair!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func benefitBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.purple)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
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

