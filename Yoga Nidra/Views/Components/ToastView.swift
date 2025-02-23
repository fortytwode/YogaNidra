//
//  ToastView.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 23/02/25.
//

import SwiftUI

struct ToastView: View {
    
    let message: String
    
    var body: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.9))
            .cornerRadius(10)
            .shadow(radius: 10)
            .padding(.top, 10)
            .padding(.horizontal, 20)
    }
}

#Preview {
    ToastView(message: "Hello")
}
