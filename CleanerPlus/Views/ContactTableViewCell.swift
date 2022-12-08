//
//  ContactTableViewCell.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/12/22.
//

import UIKit
import SwiftUI

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactDetailsLabel: UILabel!
    @IBOutlet weak var checkmarkBackgroundView: UIImageView!
    @IBOutlet weak var selectedCheckmarkView: UIImageView!
    
    func configure(contactId: String, manager: ContactsManager) {
        let contact = manager.contact(forId: contactId)
        let isContactSelected = contactId.contains("selected")
        selectedCheckmarkView.isHidden = !isContactSelected
        checkmarkBackgroundView.image = UIImage(systemName: "circle\(isContactSelected ? ".fill" : "")")
        checkmarkBackgroundView.tintColor = isContactSelected ? .white : UIColor(Color.darkGrayColor)
        contactNameLabel.text = contact?.givenName
        
        let phoneNumber = contact?.phoneNumbers.first?.value.stringValue ?? ""
        contactDetailsLabel.text = "Similar full name\(phoneNumber.isEmpty ? "" : "\n\(phoneNumber)")"
        
        guard let duplicatedFieldType = contact?.duplicatedFieldType(manager) else { return }
        switch duplicatedFieldType {
        case .email: contactDetailsLabel.text = contact?.emailAddresses.first?.value.description
        case .phoneNumber: contactDetailsLabel.text = contact?.phoneNumbers.first?.value.stringValue
        default: break
        }
    }
}

