//
//  SettingsTableViewCell.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/14/22.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingsItemLabel: UILabel!
    @IBOutlet weak var settingsItemIcon: UIImageView!
    
    func configure(item: SettingsItem) {
        settingsItemLabel.text = item.rawValue
        settingsItemIcon.image = UIImage(systemName: item.icon)
    }
}
