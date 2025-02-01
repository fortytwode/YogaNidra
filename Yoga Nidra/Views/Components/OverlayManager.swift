
import SwiftUI

@MainActor
final class OverlayManager: ObservableObject {
    
    @Published var overlay: AnyView?
    
    func showOverlay(_ overlay: some View) {
        withAnimation {
            self.overlay = AnyView(overlay)
        }
    }
    
    func hideOverlay() {
        withAnimation {
            self.overlay = nil
        }
    }
}

private struct OverlayModifier: ViewModifier {
    
    @ObservedObject var overlayManager: OverlayManager
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if let overlay = overlayManager.overlay {
                overlay
            } else {
                Color.clear.allowsHitTesting(false)
            }
        }
    }
}

extension View {
    
    func overlayContent(_ overlayManager: OverlayManager) -> some View {
        modifier(OverlayModifier(overlayManager: overlayManager))
    }
}
