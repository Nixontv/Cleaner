//
//  ContactsViewController.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/22/22.
//

import UIKit
import Combine

class ContactsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var progressLabel: UILabel!
    private let contactsManager: ContactsManager = ContactsManager()
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Similar Contacts"
        registerObservers()
        prepareTableView()
        prepareNavigationButtons()
        contactsManager.requestContactsPermission()
    }

    private func prepareTableView() {
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        tableView.contentInset = .init(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    private func registerObservers() {
        contactsManager.$showLoadingView.sink { [weak self] showLoading in
            self?.loadingStackView.isHidden = !showLoading
            if showLoading == false { self?.tableView.reloadData() }
        }.store(in: &subscriptions)

        contactsManager.$progressText.sink { [weak self] progress in
            self?.progressLabel.text = progress
        }.store(in: &subscriptions)
        
        contactsManager.$reloadIndexPath.sink { [weak self] indexPath in
            if self?.contactsManager.similarContacts.count ?? 0 > indexPath.section {
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }.store(in: &subscriptions)
    }
    
    private func prepareNavigationButtons() {
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(exitFlow))
        navigationItem.rightBarButtonItem = closeButton
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .done, target: self, action: #selector(deleteSelectedContacts))
        navigationItem.leftBarButtonItem = deleteButton
    }
    
    @objc private func exitFlow() {
        dismiss(animated: true)
    }
    
    @objc private func deleteSelectedContacts() {
        let selectedCount = contactsManager.selectedContacts.count
        if selectedCount == 0 {
            presentAlert(title: "No Contacts Selected", message: "You must select the contacts that you want to delete")
        } else {
            presentAlert(title: "Delete Selected Contacts", message: "Are you sure you want to delete \(selectedCount) selected contacts?", primaryAction: .Cancel, secondaryAction: .init(title: "Delete", style: .destructive, handler: { _ in
                self.contactsManager.deleteSelectedContacts { [weak self] in
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }))
        }
    }
}

// MARK: - Table view 
extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        contactsManager.similarContacts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactsManager.similarContacts[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactId = contactsManager.similarContacts[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let contactCell = cell as? ContactTableViewCell {
            contactCell.configure(contactId: contactId, manager: contactsManager)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactId = contactsManager.similarContacts[indexPath.section][indexPath.row]
        if contactId.contains("selected") {
            contactsManager.similarContacts[indexPath.section][indexPath.row] = contactId.replacingOccurrences(of: "-selected", with: "")
        } else {
            contactsManager.similarContacts[indexPath.section][indexPath.row] = "\(contactId)-selected"
        }
        contactsManager.reloadIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
