
import SwiftUI

struct StatView: View {
    
    let title: String
    let state: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
            Text(String(state))
                .font(.system(size: 20))
        }
    }
}
