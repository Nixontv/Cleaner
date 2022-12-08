//
//  DashboardManager.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/18/22.
//

import SwiftUI
import Foundation

class DashboardManager: NSObject, ObservableObject {
    
    @AppStorage("totalPhotosSize") var totalPhotosSize: Double?
    @AppStorage("photoPeriod") var photoPeriod: String = TimePeriod.thisMonth.rawValue
    @AppStorage(AppConfig.premiumVersion) var isPremiumUser: Bool = false
    
    /// Get percentage value for disk usage
    func percentage(diskUsageType: HeaderBottomIndicator) -> Double {
        let freeSpace = Double(UIDevice.current.freeDiskSpaceInBytes)
        let usedSpace = Double(UIDevice.current.usedDiskSpaceInBytes)
        let totalSpace = Double(UIDevice.current.totalDiskSpaceInBytes)
        switch diskUsageType {
        case .freeDiskSpace:
            return ((freeSpace * 100.0) / totalSpace) / 100.0
        case .usedDiskSpace:
            return ((usedSpace * 100.0) / totalSpace) / 100.0
        case .photoUsedDiskSpace:
            guard let photoSize = totalPhotosSize else { return 0.0 }
            return ((photoSize * 100.0) / totalSpace) / 100.0
        default: return 0.0
        }
    }
}

// MARK: - Prepare the flow for selected dashboard tile
extension DashboardManager {

    func presentFlow(forTile tile: DashboardTile) {
        Interstitial.shared.loadInterstitial()
        var controller: UINavigationController?
        
        if !isPremiumUser, !AppConfig.freeDashboardTiles.contains(tile) {
            presentAlert(title: "Premium Feature", message: "Select the Settings button and upgrade to the premium version to unlock this feature")
            return
        }
        
        switch tile {
        case .photos: controller = PhotosViewController().embedded
        case .contacts: controller = ContactsViewController().embedded
        case .calendar: controller = CalendarViewController().embedded
        case .settings: controller = SettingsViewController().embedded
        }
        
        guard let flowController = controller else { return }
        flowController.modalPresentationStyle = .fullScreen
        rootController?.present(flowController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Interstitial.shared.showInterstitialAds()
        }
    }
}

// MARK: - Prepare the flow for header bottom indicators
extension DashboardManager {
    func presentFlow(forIndicator indicator: HeaderBottomIndicator) {
        var controller: UINavigationController?
        
        switch indicator {
        case .battery: controller = BatteryTipsViewController().embedded
        default: break
        }
        
        guard let flowController = controller else { return }
        flowController.modalPresentationStyle = .fullScreen
        rootController?.present(flowController, animated: true)
    }
}
