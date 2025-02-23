
import SwiftUI

public extension View {
    
    func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}

extension View {
    
    var uiView: UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
