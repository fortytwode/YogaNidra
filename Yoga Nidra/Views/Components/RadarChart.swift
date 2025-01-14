import SwiftUI
import Foundation

struct RadarChart: View {
    let metrics: [SleepMetric]
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius = min(size.width, size.height)/2.5
            
            ZStack {
                // Background circles for better visibility
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: radius * 2.2)
                
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: radius * 2)
                
                // Grid lines
                ForEach(0..<5) { index in
                    Circle()
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: radius * 2 * CGFloat(Double(5-index) / 5))
                }
                
                // Metrics text
                ForEach(metrics.indices, id: \.self) { index in
                    let angle = (2 * Double.pi * Double(index))/Double(metrics.count) - Double.pi/2
                    let x = center.x + CGFloat(cos(angle)) * (radius + 30)
                    let y = center.y + CGFloat(sin(angle)) * (radius + 30)
                    
                    VStack {
                        Text(metrics[index].name)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        Text("\(Int(metrics[index].value * 100))%")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .position(x: x, y: y)
                }
                
                // Data polygon
                Path { path in
                    for (index, metric) in metrics.enumerated() {
                        let angle = (2 * Double.pi * Double(index))/Double(metrics.count) - Double.pi/2
                        let x = center.x + CGFloat(cos(angle)) * radius * CGFloat(metric.value)
                        let y = center.y + CGFloat(sin(angle)) * radius * CGFloat(metric.value)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .fill(Color.purple.opacity(0.6))
                
                // Outline of data polygon
                Path { path in
                    for (index, metric) in metrics.enumerated() {
                        let angle = (2 * Double.pi * Double(index))/Double(metrics.count) - Double.pi/2
                        let x = center.x + CGFloat(cos(angle)) * radius * CGFloat(metric.value)
                        let y = center.y + CGFloat(sin(angle)) * radius * CGFloat(metric.value)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .stroke(Color.purple, lineWidth: 2)
            }
        }
        .frame(height: 300)
    }
}

// Preview
struct RadarChart_Previews: PreviewProvider {
    static var previews: some View {
        RadarChart(metrics: [
            SleepMetric(name: "Sleep Quality", value: 0.8),
            SleepMetric(name: "Relaxation", value: 0.6),
            SleepMetric(name: "Energy", value: 0.7),
            SleepMetric(name: "Mental Clarity", value: 0.5),
            SleepMetric(name: "Stress Level", value: 0.4)
        ])
        .frame(width: 300, height: 300)
        .previewLayout(.sizeThatFits)
    }
}