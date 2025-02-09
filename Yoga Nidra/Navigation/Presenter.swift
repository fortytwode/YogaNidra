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
        if case .sessionDetials(let session) = destination,
           session.isPremium && !StoreManager.shared.isSubscribed {
            presenation = .subscriptionPaywall
        } else {
            presenation = destination
        }
    }
    
    func dismiss() {
        if case .sessionDetials = presenation {
            audioManager.dismissDetailView()
        }
        presenation = nil
    }
}
