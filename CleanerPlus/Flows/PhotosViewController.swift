//
//  PhotosViewController.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/22/22.
//

import UIKit
import SwiftUI
import Combine

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var progressLabel: UILabel!
    private let photosManager: PhotosManager = PhotosManager()
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    private let minimumSpacing: Double = 2.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Similar Photos"
        registerObservers()
        prepareCollectionView()
        prepareNavigationButtons()
        photosManager.requestPhotosPermission()
    }
    
    private func prepareCollectionView() {
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "cell")
        collectionView.register(UINib(nibName: "PhotoCollectionReusableView", bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    private func registerObservers() {
        photosManager.$showLoadingView.sink { [weak self] showLoading in
            self?.loadingStackView.isHidden = !showLoading
            if showLoading == false { self?.collectionView.reloadData() }
        }.store(in: &subscriptions)

        photosManager.$progressText.sink { [weak self] progress in
            self?.progressLabel.text = progress
        }.store(in: &subscriptions)
        
        photosManager.$reloadSectionIndex.sink { [weak self] section in
            if self?.photosManager.similarPhotos.count ?? 0 > section {
                self?.collectionView.reloadSections(IndexSet(integer: section))
            }
        }.store(in: &subscriptions)
        
        photosManager.$reloadIndexPath.sink { [weak self] indexPath in
            if self?.photosManager.similarPhotos.count ?? 0 > indexPath.section {
                self?.collectionView.reloadItems(at: [indexPath])
            }
        }.store(in: &subscriptions)
    }
    
    private func prepareNavigationButtons() {
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(exitFlow))
        navigationItem.rightBarButtonItem = closeButton
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .done, target: self, action: #selector(deleteSelectedPhotos))
        navigationItem.leftBarButtonItem = deleteButton
    }
    
    @objc private func exitFlow() {
        dismiss(animated: true)
    }
    
    @objc private func deleteSelectedPhotos() {
        let selectedCount = photosManager.selectedPhotos.count
        if selectedCount == 0 {
            presentAlert(title: "No Photos Selected", message: "You must select the photos that you want to delete")
        } else {
            presentAlert(title: "Delete Selected Photos", message: "Are you sure you want to delete \(selectedCount) selected photos?", primaryAction: .Cancel, secondaryAction: .init(title: "Delete", style: .destructive, handler: { _ in
                self.photosManager.deleteSelectedPhotos { [weak self] in
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                }
            }))
        }
    }
}

// MARK: - Collection view implementation
extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        photosManager.similarPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photosManager.similarPhotos[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoId = photosManager.similarPhotos[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let photoCell = cell as? PhotoCollectionViewCell {
            photoCell.configure(photoId: photoId, manager: photosManager)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoId = photosManager.similarPhotos[indexPath.section][indexPath.row]
        let photosCount = photosManager.similarPhotos[indexPath.section].count
        if photoId.contains("selected") {
            photosManager.similarPhotos[indexPath.section][indexPath.row] = photoId.replacingOccurrences(of: "-selected", with: "")
        } else {
            photosManager.similarPhotos[indexPath.section][indexPath.row] = "\(photoId)-selected"
        }
        if photosManager.similarPhotos[indexPath.section].filter({ $0.contains("selected") }).count == photosCount {
            photosManager.reloadSectionIndex = indexPath.section
        } else {
            photosManager.reloadIndexPath = indexPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.width/3.0 - minimumSpacing
        return CGSize(width: ceil(size), height: ceil(size))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if let sectionHeader = header as? PhotoCollectionReusableView {
                sectionHeader.configure(section: indexPath.section, manager: photosManager)
            }
            return header
        default:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
        }
    }
}
