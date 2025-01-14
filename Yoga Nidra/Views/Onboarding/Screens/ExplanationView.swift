import SwiftUI

struct ExplanationView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {  
            Text("What is Yoga Nidra?")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 60)  
            
            VStack(spacing: 32) {  
                // Container 1
                Text("🧘‍♀️ Yoga + 😴 Nidra = ✨ Yogic Sleep")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                
                // Container 2
                Text("🧘 Ancient Wisdom + 🔬 Modern Science = 💫 Better Sleep Tonight")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                
                // Container 3
                VStack(alignment: .leading, spacing: 24) {  
                    Text("🫀 Calms your nervous system so your mind finally quiets down.")
                    Text("🌊 Activates deep sleep brainwaves so you drift off effortlessly.")
                    Text("🧠 Optimizes sleep cycles so you wake up refreshed.")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.3))
                .cornerRadius(16)
            }
            .foregroundColor(.white)
            .font(.body)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: nextPage) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                Image("starlit-mountains")
                    .resizable()
                    .scaledToFill()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
    }
}