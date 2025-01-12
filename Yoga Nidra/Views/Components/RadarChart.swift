import SwiftUI

struct RadarChart: View {
    let metrics: [SleepMetric]
    
    var body: some View {
        VStack(spacing: 24) {
            // Radar Chart
            GeometryReader { proxy in
                let size = proxy.size
                let center = CGPoint(x: size.width/2, y: size.height/2)
                let radius = min(size.width, size.height)/3
                
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: radius * 2)
                    
                    // Metrics text
                    ForEach(metrics.indices, id: \.self) { index in
                        let angle = (2 * Double.pi * Double(index))/Double(metrics.count) - Double.pi/2
                        let x = center.x + CGFloat(cos(angle)) * (radius + 20)
                        let y = center.y + CGFloat(sin(angle)) * (radius + 20)
                        
                        VStack {
                            Text(metrics[index].name)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(Int(metrics[index].value * 100))%")
                                .font(.caption)
                                .bold()
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
                    .fill(Color.purple.opacity(0.3))
                }
            }
            .frame(height: 250)
            
            // Highlights section
            VStack(alignment: .leading, spacing: 16) {
                Text("Here are your highlights:")
                    .font(.title3)
                    .bold()
                
                ForEach(getHighlights(), id: \.title) { highlight in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(highlight.title)
                                .foregroundColor(.purple)
                            Spacer()
                            Text("\(highlight.value)%")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemRed).opacity(0.2))
                                )
                                .foregroundColor(Color(.systemRed))
                        }
                        Text(highlight.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func getHighlights() -> [(title: String, value: Int, description: String)] {
        let sortedMetrics = metrics.sorted { $0.value > $1.value }
        let topMetric = sortedMetrics.first!
        let bottomMetric = sortedMetrics.last!
        
        return [
            (
                title: "Strength",
                value: Int(topMetric.value * 100),
                description: getStrengthDescription(for: topMetric.name)
            ),
            (
                title: "Growth area",
                value: Int(bottomMetric.value * 100),
                description: getGrowthDescription(for: bottomMetric.name)
            )
        ]
    }
    
    private func getStrengthDescription(for metric: String) -> String {
        // Customize based on the metric
        switch metric {
        case "Sleep Quality": return "You're maintaining good sleep habits!"
        case "Relaxation": return "You have a good foundation for relaxation"
        case "Energy": return "Your energy levels are well maintained"
        case "Mental Clarity": return "You're maintaining good mental focus"
        case "Stress Level": return "You're managing stress effectively"
        default: return "You're doing well in this area"
        }
    }
    
    private func getGrowthDescription(for metric: String) -> String {
        // Customize based on the metric
        switch metric {
        case "Sleep Quality": return "We'll help you improve your sleep quality"
        case "Relaxation": return "Let's work on better relaxation techniques"
        case "Energy": return "We'll help boost your energy levels"
        case "Mental Clarity": return "We'll help enhance your mental clarity"
        case "Stress Level": return "We'll help you better manage stress"
        default: return "We'll help you improve in this area"
        }
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