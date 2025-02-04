//
//  OnLoadModifier.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 16/01/25.
//

import SwiftUI

@MainActor
struct OnLoadModifier: ViewModifier {
    let action: () async throws -> Void
    
    @State private var hasLoaded = false
    
    func body(content: Content) -> some View {
        content
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                do {
                    try await action()
                } catch {
                    print("OnLoad action failed: \(error)")
                }
            }
    }
}

extension View {
    func onLoad(perform action: @escaping () async throws -> Void) -> some View {
        modifier(OnLoadModifier(action: action))
    }
}
