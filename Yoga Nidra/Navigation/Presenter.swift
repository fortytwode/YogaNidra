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
    
    func present(_ destination: SheetPresentaiton) {
        switch destination {
        case .subscriptionPaywall:
            presenation = .subscriptionPaywall
        case .sessionDetials(let session):
            if session.isPremium && !StoreManager.shared.isSubscribed {
                presenation = .subscriptionPaywall
            } else {
                presenation = destination
                Task {
                    audioManager.prepareSession(session)
                    await audioManager.startPreparedSession()
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
