//
//  AppDelegate.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 09/03/25.
//

import UIKit
import Firebase
import FBSDKCoreKit
import RevenueCat
import SuperwallKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        firebase()
        notification()
        setupFacebookSDK(launchOptions: launchOptions)
        
        // Initialize RevenueCat
        configureRevenueCat()
        
        // Initialize Superwall with your API key
        configureSuperwallSDK()
        
        return true
    }
    
    private func configureRevenueCat() {
        // Configure RevenueCat with the most basic configuration
        Purchases.configure(withAPIKey: "appl_KDvjJIUgkZHCeRNGQZCsJlrMFbB")
    }
    
    private func configureSuperwallSDK() {
        // Simple configuration with just the API key
        Superwall.configure(apiKey: "pk_43c10a21c60615dc63a3862187df3ced631ac5742bdd23db")
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
