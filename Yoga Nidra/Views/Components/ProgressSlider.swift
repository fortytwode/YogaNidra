import SwiftUI

struct ProgressSlider: View {
    @Binding var value: TimeInterval
    let maxValue: TimeInterval
    let onEditingChanged: (Bool) -> Void
    
    @State private var isEditing = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                // Progress track
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * CGFloat(value / maxValue), height: 4)
                
                // Drag handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .offset(x: geometry.size.width * CGFloat(value / maxValue) - 8)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isEditing = true
                                onEditingChanged(true)
                                let newValue = min(maxValue, max(0, TimeInterval(gesture.location.x / geometry.size.width) * maxValue))
                                value = newValue
                            }
                            .onEnded { _ in
                                isEditing = false
                                onEditingChanged(false)
                            }
                    )
            }
        }
        .frame(height: 16)
    }
} 