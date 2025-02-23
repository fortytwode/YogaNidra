//
//  RechabilityManager.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 23/02/25.
//

import SwiftUI
import Connectivity
import Combine

final class RechabilityManager: ObservableObject {
    static let shared = RechabilityManager()
    
    @MainActor @Published var isNetworkRechable = true
    
    private let connectivity = Connectivity()
    
    private let rechabilityChanged = PassthroughSubject<Void, Never>()
    var rechabilityChangedPublisher: AnyPublisher<Void, Never> {
        rechabilityChanged.eraseToAnyPublisher()
    }
    
    private init() {
        connectivity.startNotifier()
        let onConnectiviytChanged = { [weak self] (connectivity: Connectivity) -> Void in
            switch connectivity.status {
            case .connected, .connectedViaCellular, .connectedViaEthernet, .connectedViaWiFi:
                Task { @MainActor in
                    self?.isNetworkRechable = true
                    self?.rechabilityChanged.send()
                }
            default:
                Task { @MainActor in
                    self?.isNetworkRechable = false
                    self?.rechabilityChanged.send()
                }
            }
        }
        connectivity.whenConnected = onConnectiviytChanged
        connectivity.whenDisconnected = onConnectiviytChanged
        connectivity.isPollingEnabled = true
    }
}
