//
//  AppDesntinations.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 18/01/25.
//

import Foundation

enum SheetPresentaiton: Identifiable, Hashable {
    case subscriptionPaywall
    case sessionDetials(_ session: YogaNidraSession)
    
    var id: Int {
        hashValue
    }
}

enum HomeTabDestination: Hashable {
    case springReset
}

enum LibraryTabDestination: Hashable {
    case none
}

enum DisoverTabDestination: Hashable {
    case selfLove14Days
    case springReset
}

enum ProgileTabDestination: Hashable {
    case settings
}
