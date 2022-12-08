//
//  SettingsViewController.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/22/22.
//

import UIKit
import SwiftUI
import StoreKit
import MessageUI
import PurchaseKit

class SettingsViewController: UIViewController {

    @AppStorage(AppConfig.premiumVersion) var isPremiumUser: Bool = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var loadingViewBackground: UIView!
    private let settingsGroups: [[SettingsItem]] = [
        [.premiumUpgrade, .restorePurchases],
        [.rateApp, .shareApp], [.email, .privacy, .terms]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        prepareTableView()
        prepareNavigationButtons()
    }

    private func prepareTableView() {
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        tableView.contentInset = .init(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    private func prepareNavigationButtons() {
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(exitFlow))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func exitFlow() {
        dismiss(animated: true)
    }
}

// MARK: - Table view implementation
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        settingsGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsGroups[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = settingsGroups[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let settingsCell = cell as? SettingsTableViewCell {
            settingsCell.configure(item: item)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = settingsGroups[indexPath.section][indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        switch item {
        case .premiumUpgrade:
            premiumUpgrade()
        case .restorePurchases:
            restorePurchases()
        case .rateApp:
            rateApp()
        case .shareApp:
            shareApp()
        case .email:
            EmailPresenter.shared.present()
        case .privacy:
            UIApplication.shared.open(AppConfig.privacyURL, options: [:], completionHandler: nil)
        case .terms:
            UIApplication.shared.open(AppConfig.termsAndConditionsURL, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Handle settings items
extension SettingsViewController {

    func premiumUpgrade() {
        showLoadingView(true)
        PKManager.purchaseProduct(identifier: AppConfig.premiumVersion) { _, status, _ in
            DispatchQueue.main.async {
                self.showLoadingView(false)
                if status == .success {
                    self.isPremiumUser = true
                }
            }
        }
    }
    
    func restorePurchases() {
        showLoadingView(true)
        PKManager.restorePurchases { _, status, _ in
            DispatchQueue.main.async {
                self.showLoadingView(false)
                if status == .restored {
                    self.isPremiumUser = true
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showLoadingView(false)
        }
    }
    
    func rateApp() {
        if let scene = UIApplication.shared.windows.first?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func shareApp() {
        let shareController = UIActivityViewController(activityItems: [AppConfig.yourAppURL], applicationActivities: nil)
        rootController?.present(shareController, animated: true, completion: nil)
    }
    
    private func showLoadingView(_ show: Bool) {
        loadingStackView.isHidden = !show
        loadingViewBackground.isHidden = !show
    }
}

// MARK: - Mail presenter for SwiftUI
class EmailPresenter: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailPresenter()
    private override init() { }
    
    func present() {
        if !MFMailComposeViewController.canSendMail() {
            presentAlert(title: "Email Client", message: "Your device must have the native iOS email app installed for this feature.")
            return
        }
        let picker = MFMailComposeViewController()
        picker.setToRecipients([AppConfig.emailSupport])
        picker.mailComposeDelegate = self
        rootController?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        rootController?.dismiss(animated: true, completion: nil)
    }
}
