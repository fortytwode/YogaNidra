//
//  InitializationState.swift
//  Yoga Nidra
//
//  Created on 2025-04-03.
//

import Foundation

// Non-actor-isolated class for tracking initialization state
// This class can be accessed from any context, including background tasks
final class InitializationState {
    private let queue = DispatchQueue(label: "com.yoganidra.initializationState")
    private var _isInitializing = true
    
    var isInitializing: Bool {
        get { queue.sync { _isInitializing } }
        set { queue.sync { _isInitializing = newValue } }
    }
}
