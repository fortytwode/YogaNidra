//
//  AppDelegate.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 09/03/25.
//

import UIKit
import Firebase
import FBSDKCoreKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        firebase()
        notification()
        setupFacebookSDK(launchOptions: launchOptions)
        return true
    }
    
    private func setupFacebookSDK(launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            options: options
        )
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
