//
//  OnLoadModifier.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 16/01/25.
//


import SwiftUI

struct OnLoadModifier: ViewModifier {
    let action: () -> Void

    @State private var hasLoaded = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !hasLoaded {
                    hasLoaded = true
                    action()
                }
            }
    }
}

extension View {
    func onLoad(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnLoadModifier(action: action))
    }
}