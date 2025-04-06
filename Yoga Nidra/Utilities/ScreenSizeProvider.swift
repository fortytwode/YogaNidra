import SwiftUI

class ScreenSizeProvider: ObservableObject {
    @Published var scaleFactor: CGFloat = 1.0
    private let referenceSize: CGSize = CGSize(width: 390, height: 844) // iPhone 13 Pro size
    
    func updateScaleFactor(for size: CGSize) {
        scaleFactor = min(
            size.width / referenceSize.width,
            size.height / referenceSize.height
        )
    }
}

struct ScalableAppModifier: ViewModifier {
    @StateObject private var sizeProvider = ScreenSizeProvider()
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environmentObject(sizeProvider)
                .onAppear {
                    sizeProvider.updateScaleFactor(for: geometry.size)
                }
                .onChange(of: geometry.size) { newSize in
                    sizeProvider.updateScaleFactor(for: newSize)
                }
        }
    }
}

extension View {
    func scalableApp() -> some View {
        self.modifier(ScalableAppModifier())
    }
}
