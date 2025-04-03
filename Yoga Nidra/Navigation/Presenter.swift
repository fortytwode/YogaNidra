//
//  Presenter.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 18/01/25.
//

import Foundation

@MainActor
final class Presenter: ObservableObject {
    
    @Published var presenation: SheetPresentaiton?
    private let audioManager = AudioManager.shared
    
    // MARK: - Preview Helper
    #if DEBUG
    static var preview: Presenter {
        let presenter = Presenter()
        // No need to set any presentation by default
        return presenter
    }
    #endif
    
    func present(_ destination: SheetPresentaiton) {
        switch destination {
        case .subscriptionPaywall:
            presenation = .subscriptionPaywall
        case .sessionDetials(let session):
            // Always show session details first
            presenation = destination
            if audioManager.currentPlayingSession != session {
                Task {
                    audioManager.prepareSession(session)
                    // Don't auto-start premium sessions
                    if !session.isPremium || StoreManager.shared.isSubscribed {
                        await audioManager.startPreparedSession()
                    }
                }
            }
        }
    }
    
    func dismiss() {
        if case .sessionDetials = presenation {
            audioManager.dismissDetailView()
        }
        presenation = nil
    }
}
