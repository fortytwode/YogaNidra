import SwiftUI

struct SleepPatternView: View {
    @State private var selectedDuration: String?
    
    let options = [
        "Less than 6 hours",
        "6-8 hours",
        "8-10 hours",
        "More than 10 hours"
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("How much sleep do you\nusually get?")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("We'll help you optimize your rest")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selectedDuration = option
                    } label: {
                        HStack {
                            Text(option)
                                .font(.headline)
                            Spacer()
                            if selectedDuration == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .systemGray6))
                        )
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            if selectedDuration != nil {
                Text("Swipe to continue")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 24)
    }
} 