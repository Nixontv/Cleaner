//
//  ContactsManager.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/12/22.
//

import UIKit
import SwiftUI
import CoreData
import Contacts
import Foundation

class ContactsManager: NSObject, ObservableObject {
    
    var similarContacts: [[String]] = [[String]]()
    var duplicatedFields: [CNContact.FieldType: [String]] = [CNContact.FieldType: [String]]()
    @Published var progressText: String = "please wait..."
    @Published var showLoadingView: Bool = false
    @Published var reloadIndexPath: IndexPath = IndexPath(row: 0, section: Int.max)
    
    private var contacts: [CNContact] = [CNContact]()
    
    var selectedContacts: [String] {
        similarContacts.filter({ $0.contains(where: { $0.contains("selected") })})
            .flatMap({ $0 }).filter({ $0.contains("selected") })
    }
    
    func contact(forId identifier: String) -> CNContact? {
        contacts.first(where: { $0.identifier == identifier.replacingOccurrences(of: "-selected", with: "") })
    }
    
    func requestContactsPermission() {
        showLoadingView = true
        CNContactStore().requestAccess(for: .contacts) { accessGranted, _ in
            DispatchQueue.main.async {
                if accessGranted { self.fetchContacts() } else {
                    self.showLoadingView = false
                }
            }
        }
    }
    
    func fetchContacts() {
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        try? CNContactStore().enumerateContacts(with: fetchRequest) { contact, _ in
            self.contacts.append(contact)
        }
        processSimilarContacts()
    }
    
    private func processSimilarContacts() {
        let nameCrossReference = Dictionary(grouping: contacts, by: \.fullName)
        let phoneNumberCrossReference = Dictionary(grouping: contacts, by: \.phoneNumbers.first?.value.stringValue)
        let emailCrossReference = Dictionary(grouping: contacts, by: \.emailAddresses.first?.value)
        processDuplicates(nameCrossReference, validator: .none)
        processDuplicates(phoneNumberCrossReference, validator: .phoneNumber)
        processDuplicates(emailCrossReference, validator: .email)
        showLoadingView = false
    }
    
    private func processDuplicates(_ dictionary: [AnyHashable: [CNContact]], validator: CNContact.FieldType) {
        dictionary.filter { $1.count > 1 }.forEach { _, contacts in
            var similarItems = contacts
            switch validator {
            case .email:
                similarItems = similarItems.filter { $0.emailAddresses.first != nil }
            case .phoneNumber:
                similarItems = similarItems.filter { $0.phoneNumbers.first != nil }
            default: break
            }
            if similarItems.count > 1 {
                let similarItemsIds = similarItems.compactMap { $0.identifier }
                similarContacts.append(similarItemsIds)
                duplicatedFields[validator] = similarItemsIds
            }
        }
    }
}

// MARK: - Contacts extension
extension CNContact {
    var fullName: String {
        givenName.lowercased() + " " + familyName.lowercased()
    }
    
    enum FieldType: String {
        case none, email, phoneNumber
    }
    
    func duplicatedFieldType(_ manager: ContactsManager) -> FieldType? {
        manager.duplicatedFields.first(where: { $0.value.contains(identifier)} )?.key
    }
}

// MARK: - Delete selected contacts
extension ContactsManager {

    func deleteSelectedContacts(completion: @escaping () -> Void) {
        let saveRequest = CNSaveRequest()
        let selectedIds = selectedContacts.map { $0.replacingOccurrences(of: "-selected", with: "") }
        let mutableContacts = selectedIds.map { id in contacts.first(where: { $0.identifier == id }) }
        mutableContacts.filter { $0 != nil}.forEach { saveRequest.delete($0!.mutableCopy() as! CNMutableContact) }
        do {
            try CNContactStore().execute(saveRequest)
            self.similarContacts.enumerated().forEach { index, group in
                self.similarContacts[index] = group.filter({ !self.selectedContacts.contains($0) })
            }
            completion()
        } catch let error {
            presentAlert(title: "Oops!", message: error.localizedDescription)
        }
    }
}
