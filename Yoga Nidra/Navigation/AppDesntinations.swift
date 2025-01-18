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
    case none
}

enum LibraryTabDestination: Hashable {
    case none
}

enum ProgressTabDestination: Hashable {
    case none
}
