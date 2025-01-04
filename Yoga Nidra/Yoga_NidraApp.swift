//
//  Yoga_NidraApp.swift
//  Yoga Nidra
//
//  Created by Shamanth Rao on 1/1/25.
//

import SwiftUI

@main
struct Yoga_NidraApp: App {
    // Initialize the shared manager at app launch
    @StateObject private var progressManager = ProgressManager.shared
    
    // Add this to toggle between views (optional, for testing)
    @AppStorage("useNewHomeView") private var useNewHomeView = true
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView_v2()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                SessionListView_v2()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical.fill")
                    }
                
                ProgressTabView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
            }
            .environmentObject(progressManager)
        }
    }
}
