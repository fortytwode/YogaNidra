//
//  Router.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 18/01/25.
//

import Foundation

@MainActor
final class Router<T: Hashable>: ObservableObject {
    
    @Published var path: [T] = []
    
    func push(_ destination: T) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeAll()
    }
}
