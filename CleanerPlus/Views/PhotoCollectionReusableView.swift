//
//  PhotoCollectionReusableView.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/11/22.
//

import UIKit

class PhotoCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var photosCountLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    private var photosManager: PhotosManager?
    private var sectionIndex: Int?
    
    @IBAction func selectAction(_ sender: UIButton) {
        guard let section = sectionIndex, let manager = photosManager else { return }
        selectButton.isSelected = !selectButton.isSelected
        if selectButton.isSelected {
            let photoIds = manager.similarPhotos[section]
            manager.similarPhotos[section] = photoIds.map { "\($0)-selected" }
        } else {
            let photoIds = manager.similarPhotos[section]
            manager.similarPhotos[section] = photoIds.map { $0.replacingOccurrences(of: "-selected", with: "") }
        }
        manager.reloadSectionIndex = section
    }
    
    func configure(section: Int, manager: PhotosManager) {
        let photosCount = manager.similarPhotos[section].count
        photosCountLabel.text = "\(photosCount) photos"
        selectButton.isSelected = manager.similarPhotos[section].filter { $0.contains("selected") }.count == photosCount
        photosManager = manager
        sectionIndex = section
    }
}

