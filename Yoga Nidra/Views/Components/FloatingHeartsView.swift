import SwiftUI

struct FloatingHeart: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var rotation: Angle
}

struct FloatingHeartsView: View {
    @State private var hearts: [FloatingHeart] = []
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink.opacity(0.6))
                    .scaleEffect(heart.scale)
                    .opacity(heart.opacity)
                    .rotationEffect(heart.rotation)
                    .position(heart.position)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onReceive(timer) { _ in
            addHearts()
        }
    }
    
    private func addHearts() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Add 3-5 hearts at once for increased density
        let heartCount = Int.random(in: 3...5)
        
        for _ in 0..<heartCount {
            let heart = FloatingHeart(
                position: CGPoint(
                    x: CGFloat.random(in: 20...screenWidth-20),
                    y: -50
                ),
                scale: CGFloat.random(in: 0.6...1.8),
                opacity: 1.0,
                rotation: Angle.degrees(Double.random(in: -20...20))
            )
            
            hearts.append(heart)
            
            withAnimation(.easeIn(duration: CGFloat.random(in: 4...6))) {
                if let index = hearts.firstIndex(where: { $0.id == heart.id }) {
                    hearts[index].position.y += screenHeight + 100
                    hearts[index].opacity = 0
                }
            }
            
            // Remove heart after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                hearts.removeAll { $0.id == heart.id }
            }
        }
    }
}

struct FloatingLeaf: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var rotation: Angle
}

struct FloatingLeavesView: View {
    @State private var leaves: [FloatingLeaf] = []
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(leaves) { leaf in
                Image(systemName: "leaf.fill")
                    .foregroundColor([.green, .yellow, .orange].randomElement()!)
                    .scaleEffect(leaf.scale)
                    .opacity(leaf.opacity)
                    .rotationEffect(leaf.rotation)
                    .position(leaf.position)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onReceive(timer) { _ in
            addLeaf()
        }
    }
    
    private func addLeaf() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let leaf = FloatingLeaf(
            position: CGPoint(
                x: CGFloat.random(in: 50...screenWidth-50),
                y: -50
            ),
            scale: CGFloat.random(in: 0.5...1.5),
            opacity: 1.0,
            rotation: Angle.degrees(Double.random(in: 0...360))
        )
        
        leaves.append(leaf)
        
        withAnimation(.easeIn(duration: 5)) {
            if let index = leaves.firstIndex(where: { $0.id == leaf.id }) {
                leaves[index].position.y += screenHeight + 50
                leaves[index].opacity = 0
            }
        }
        
        // Remove leaf after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            leaves.removeAll { $0.id == leaf.id }
        }
    }
}
