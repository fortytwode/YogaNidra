//
//  ToastView.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 23/02/25.
//

import SwiftUI

struct ToastView: View {
    
    let message: String
    let backgroundColor: Color
    
    var body: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(10)
            .shadow(radius: 10)
            .padding(.top, 10)
            .padding(.horizontal, 20)
    }
}

#Preview {
    ToastView(message: "Hello", backgroundColor: Color.red.opacity(0.9))
}
