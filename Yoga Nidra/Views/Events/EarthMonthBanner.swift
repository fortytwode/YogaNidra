
import SwiftUI

struct EarthMonthBanner: View {
    
    var body: some View {
        ZStack {
            Image("Earth_Heartbeat")
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.brown.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                )
            VStack {
                Text("Earth Month")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                Text("Earth Month")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                .padding()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    EarthMonthBanner()
}
