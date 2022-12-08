//
//  AppConfig.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/21/22.
//

import UIKit
import SwiftUI
import Foundation

class AppConfig {
    
    static let adMobAdId: String = ""
    
    // MARK: - Settings flow items
    static let emailSupport = ""
    static let privacyURL: URL = URL(string: "")!
    static let termsAndConditionsURL: URL = URL(string: "")!
    static let yourAppURL: URL = URL(string: "")!
    
    // MARK: - Generic Configurations
    static let appLaunchDelay: TimeInterval = 1.5
    static let maxPhotosCount: Int = -1
    
    // MARK: - In App Purchases
    static let premiumVersion: String = "CleanerPlus.Premium"
    static let freeDashboardTiles: [DashboardTile] = [.calendar, .contacts, .settings]
    
    // MARK: - Battery Level
    static var batteryPercentage: Int {
        if UIDevice.current.batteryLevel < 0 {
            return 0
        }
        return Int(UIDevice.current.batteryLevel * 100.0)
    }
}

// MARK: - Dashboard Tiles type
enum DashboardTile: String, CaseIterable, Identifiable {
    case photos, contacts, calendar, settings
    var id: Int { hashValue }
    
    var icon: String {
        switch self {
        case .photos: return "photo"
        case .contacts: return "person.fill"
        case .calendar: return "calendar"
        case .settings: return "gearshape.fill"
        }
    }
    
    var subtitle: String {
        switch self {
        case .photos: return "Clean similar items"
        case .contacts: return "Find duplicates"
        case .calendar: return "Clean old events"
        case .settings: return "Adjust app settings"
        }
    }
}

// MARK: - Settings items
enum SettingsItem: String {
    case premiumUpgrade = "Premium Version"
    case restorePurchases = "Restore Purchases"
    case rateApp = "Rate App"
    case shareApp = "Share App"
    case email = "E-Mail us"
    case privacy = "Privacy Policy"
    case terms = "Terms of Use"
    
    var icon: String {
        switch self {
        case .premiumUpgrade:
            return "crown"
        case .restorePurchases:
            return "arrow.clockwise"
        case .rateApp:
            return "star"
        case .shareApp:
            return "square.and.arrow.up"
        case .email:
            return "envelope.badge"
        case .privacy:
            return "hand.raised"
        case .terms:
            return "doc.text"
        }
    }
}

// MARK: - Battery tips items
enum BatteryTipItem: String, CaseIterable {
    case update = "Update to the latest software"
    case optimized = "Optimize your settings"
    case powerMode = "Enable Low Power Mode"
    case avoidHighTemp = "Avoid extreme ambient temperatures"
    case removeCases = "Remove certain cases during charging"
    
    var details: String {
        switch self {
        case .update:
            return "Always make sure your device is using the latest version of iOS. Each version has some battery improvements changes."
        case .optimized:
            return "There are two simple ways you can preserve battery life — no matter how you use your device:\n- adjust your screen brightness\n- use Wi‑Fi"
        case .powerMode:
            return "Introduced with iOS 9, Low Power Mode is an easy way to extend the battery life of your iPhone when it starts to get low. Your iPhone lets you know when your battery level goes down to 20%, and again at 10%, and lets you turn on Low Power Mode with one tap."
        case .avoidHighTemp:
            return "Your device is designed to perform well in a wide range of ambient temperatures, with 62° to 72° F (16° to 22° C) as the ideal comfort zone. It’s especially important to avoid exposing your device to ambient temperatures higher than 95° F (35° C), which can permanently damage battery capacity."
        case .removeCases:
            return "Charging your device when it’s inside certain styles of cases may generate excess heat, which can affect battery capacity. If you notice that your device gets hot when you charge it, take it out of its case first."
        }
    }
}

// MARK: - Color configurations
extension Color {
    static let whiteColor: Color = Color("WhiteColor")
    static let darkGrayColor: Color = Color("DarkGrayColor")
    static let extraDarkGrayColor: Color = Color("ExtraDarkGrayColor")
    static let accentLightColor: Color = Color("AccentLightColor")
    static let backgroundColor: Color = Color("BackgroundColor")
    static let lightBlueColor: Color = Color("LightBlueColor")
    static let lightColor: Color = Color("LightColor")
    static let lightGrayColor: Color = Color("LightGrayColor")
    static let redStartColor: Color = Color("RedStartColor")
    static let redEndColor: Color = Color("RedEndColor")
}
