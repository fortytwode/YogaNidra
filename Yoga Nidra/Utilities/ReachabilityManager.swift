//
//  ReachabilityManager.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 23/02/25.
//

import SwiftUI
import Connectivity
import Combine

final class ReachabilityManager: ObservableObject {
    static let shared = ReachabilityManager()
    
    @MainActor @Published var isNetworkReachable = true
    
    private let connectivity = Connectivity()
    
    private let reachabilityChanged = PassthroughSubject<Void, Never>()
    var reachabilityChangedPublisher: AnyPublisher<Void, Never> {
        reachabilityChanged.eraseToAnyPublisher()
    }
    
    private init() {
        connectivity.startNotifier()
        let onConnectiviytChanged = { [weak self] (connectivity: Connectivity) -> Void in
            switch connectivity.status {
            case .connected, .connectedViaCellular, .connectedViaEthernet, .connectedViaWiFi:
                Task { @MainActor in
                    let oldValue = self?.isNetworkReachable
                    self?.isNetworkReachable = true
                    if oldValue != true {
                        self?.reachabilityChanged.send()
                    }
                }
            default:
                Task { @MainActor in
                    let oldValue = self?.isNetworkReachable
                    self?.isNetworkReachable = false
                    if oldValue != false {
                        self?.reachabilityChanged.send()
                    }
                }
            }
        }
        connectivity.whenConnected = onConnectiviytChanged
        connectivity.whenDisconnected = onConnectiviytChanged
        connectivity.isPollingEnabled = true
    }
}
