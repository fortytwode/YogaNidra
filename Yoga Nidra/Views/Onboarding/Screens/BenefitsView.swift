import SwiftUI

struct BenefitsView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Ancient yogic wisdom + modern science = better sleep.")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 24) {
                benefitRow(
                    icon: "brain.head.profile",
                    title: "Relax and unwind deeply from within",
                    description: "Proven to reduce stress by 44% after a single session"
                )
                
                benefitRow(
                    icon: "moon.zzz.fill",
                    title: "Sleep faster, deeper",
                    description: "Mindfulness techniques shown to cut the time to fall asleep by up to 37%"
                )
                
                benefitRow(
                    icon: "sunrise.fill",
                    title: "Wake up refreshed",
                    description: "20 minutes of Yoga Nidra can provide restorative benefits similar to 2-3 hours of sleep"
                )
            }
            .padding(24)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(16)
            
            Spacer()
            
            Button(action: nextPage) {
                Text("Get your personalized Yoga Nidra meditation")
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
} 