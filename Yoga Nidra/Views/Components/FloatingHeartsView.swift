import SwiftUI

struct FloatingHeart: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
}

struct FloatingHeartsView: View {
    @State private var hearts: [FloatingHeart] = []
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink.opacity(0.3))
                    .scaleEffect(heart.scale)
                    .opacity(heart.opacity)
                    .position(heart.position)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onReceive(timer) { _ in
            addHeart()
        }
    }
    
    private func addHeart() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let heart = FloatingHeart(
            position: CGPoint(
                x: CGFloat.random(in: 50...screenWidth-50),
                y: screenHeight
            ),
            scale: CGFloat.random(in: 0.5...1.5),
            opacity: 0.8
        )
        
        hearts.append(heart)
        
        withAnimation(.easeOut(duration: 4)) {
            if let index = hearts.firstIndex(where: { $0.id == heart.id }) {
                hearts[index].position.y -= CGFloat.random(in: 200...400)
                hearts[index].opacity = 0
            }
        }
        
        // Remove heart after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            hearts.removeAll { $0.id == heart.id }
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
