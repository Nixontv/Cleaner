//
//  CalendarTableViewCell.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/12/22.
//

import UIKit
import SwiftUI

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDetailsLabel: UILabel!
    @IBOutlet weak var checkmarkBackgroundView: UIImageView!
    @IBOutlet weak var selectedCheckmarkView: UIImageView!
    
    func configure(eventId: String, year: String, manager: CalendarManager) {
        let event = manager.event(forId: eventId, year: year)
        let isEventSelected = eventId.contains("selected")
        selectedCheckmarkView.isHidden = !isEventSelected
        checkmarkBackgroundView.image = UIImage(systemName: "circle\(isEventSelected ? ".fill" : "")")
        checkmarkBackgroundView.tintColor = isEventSelected ? .white : UIColor(Color.darkGrayColor)
        eventNameLabel.text = event?.title
        eventDateLabel.text = event?.startDate.string(format: "MMM d, yyyy")
        eventDetailsLabel.text = "Calendar: \(event?.calendar.title ?? "")"
    }
}
