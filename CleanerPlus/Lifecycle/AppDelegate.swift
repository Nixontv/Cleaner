//
//  AppDelegate.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/21/22.
//

import UIKit
import Foundation
import PurchaseKit
import GoogleMobileAds
import AppTrackingTransparency

/// App Delegate file in SwiftUI
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        PKManager.loadProducts(identifiers: [AppConfig.premiumVersion])
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in self.requestIDFA() }
        Thread.sleep(forTimeInterval: AppConfig.appLaunchDelay)
        return true
    }
    
    func requestIDFA() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}

// MARK: - Google AdMob Interstitial - Support class
class Interstitial: NSObject, GADFullScreenContentDelegate {
    var isPremiumUser: Bool = UserDefaults.standard.bool(forKey: AppConfig.premiumVersion)
    private var interstitial: GADInterstitialAd?
    static var shared: Interstitial = Interstitial()
    
    override init() {
        super.init()
        loadInterstitial()
    }
    
    func loadInterstitial() {
        if isPremiumUser == false {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: AppConfig.adMobAdId, request: request, completionHandler: { [self] ad, error in
                if ad != nil { interstitial = ad }
                interstitial?.fullScreenContentDelegate = self
            })
        }
    }
    
    func showInterstitialAds() {
        if interstitial != nil, !isPremiumUser, let root = rootController {
            interstitial?.present(fromRootViewController: root)
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial()
    }
}
