//
//  TipsTableViewCell.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/12/22.
//

import UIKit

class TipsTableViewCell: UITableViewCell {

    @IBOutlet weak var tipTitleLabel: UILabel!
    @IBOutlet weak var tipDetailsLabel: UILabel!
    
    func configure(item: BatteryTipItem) {
        tipTitleLabel.text = item.rawValue
        tipDetailsLabel.text = item.details
    }
}
