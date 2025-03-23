//
//  AppDelegate.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 09/03/25.
//

import UIKit
import Firebase

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        firebase()
        notification()
        return true
    }
    
    private func firebase() {
        FirebaseApp.configure()
    }
    
    private func notification() {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.badge, .sound, .banner, .list]
    }
}
