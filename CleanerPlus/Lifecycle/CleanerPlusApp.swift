//
//  CleanerPlusApp.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/21/22.
//

import UIKit
import SwiftUI

@main
struct CleanerPlusApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var manager: DashboardManager = DashboardManager()

    // MARK: - Main rendering function
    var body: some Scene {
        WindowGroup {
            DashboardContentView().environmentObject(manager)
        }
    }
}

func presentAlert(title: String, message: String, primaryAction: UIAlertAction = .OK, secondaryAction: UIAlertAction? = nil, tertiaryAction: UIAlertAction? = nil) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(primaryAction)
        if let secondary = secondaryAction { alert.addAction(secondary) }
        if let tertiary = tertiaryAction { alert.addAction(tertiary) }
        rootController?.present(alert, animated: true, completion: nil)
    }
}

extension UIAlertAction {
    static var OK: UIAlertAction {
        UIAlertAction(title: "OK", style: .cancel, handler: nil)
    }
    
    static var Cancel: UIAlertAction {
        UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
}

var rootController: UIViewController? {
    var root = UIApplication.shared.windows.first?.rootViewController
    while root?.presentedViewController != nil {
        root = root?.presentedViewController
    }
    return root
}

extension UIViewController {
    var embedded: UINavigationController {
        let controller = UINavigationController(rootViewController: self)
        controller.navigationBar.prefersLargeTitles = false
        return controller
    }
}

extension Date {
    func string(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension UIDevice {
    var totalDiskSpace: String {
        totalDiskSpaceInBytes.formattedBytes
    }
    
    var freeDiskSpace: String {
        freeDiskSpaceInBytes.formattedBytes
    }
    
    var usedDiskSpace: String {
        usedDiskSpaceInBytes.formattedBytes
    }
    
    var totalDiskSpaceInBytes: Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }

    var freeDiskSpaceInBytes: Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
               let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes: Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
}

extension Int64 {
    var formattedBytes: String {
        if (self < 1000) { return "\(self) B" }
        let exp = Int(log2(Double(self)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(self) / pow(1000, Double(exp))
        if exp <= 1 || number >= 100 {
            return String(format: "%.0f %@", number, unit)
        } else {
            return String(format: "%.1f %@", number, unit).replacingOccurrences(of: ".0", with: "")
        }
    }
}

extension String {
    var double: Double? {
        Double(replacingOccurrences(of: " GB", with: "")
            .replacingOccurrences(of: " MB", with: "")
            .replacingOccurrences(of: " KB", with: "")
            .replacingOccurrences(of: " B", with: "")
        )
    }
    
    var formatted: String {
        replacingOccurrences(of: " GB", with: "\nGB")
        .replacingOccurrences(of: " MB", with: "\nMB")
        .replacingOccurrences(of: " KB", with: "\nKB")
        .replacingOccurrences(of: " B", with: "\nB")
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

