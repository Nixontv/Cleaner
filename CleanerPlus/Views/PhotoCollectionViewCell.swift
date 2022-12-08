//
//  PhotoCollectionViewCell.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/11/22.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkmarkBackgroundView: UIImageView!
    @IBOutlet weak var selectedOverlay: UIView!
    @IBOutlet weak var selectedCheckmarkView: UIImageView!
    
    func configure(photoId: String, manager: PhotosManager) {
        let isPhotoSelected = photoId.contains("selected")
        imageView.image = manager.image(forId: photoId)
        selectedOverlay.isHidden = !isPhotoSelected
        selectedCheckmarkView.isHidden = !isPhotoSelected
        checkmarkBackgroundView.image = UIImage(systemName: "circle\(isPhotoSelected ? ".fill" : "")")
    }
}
