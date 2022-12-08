//
//  PhotosManager.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/22/22.
//

import UIKit
import Photos
import Vision
import SwiftUI
import CoreData
import Foundation

class PhotosManager: NSObject, ObservableObject {
    
    var similarPhotos: [[String]] = [[String]]()
    @Published var progressText: String = "please wait..."
    @Published var showLoadingView: Bool = false
    @Published var reloadSectionIndex: Int = 0
    @Published var reloadIndexPath: IndexPath = IndexPath(row: 0, section: Int.max)
    
    @AppStorvage("totalPhotosSize") var totalPhotosSize: Double?
    @AppStorage("photoPeriod") var photoPeriod: String = TimePeriod.thisMonth.rawValue
    
    private var photos: [UIImage] = [UIImage]()
    private var featurePrints: [String: VNFeaturePrintObservation] = [String: VNFeaturePrintObservation]()
    private let similarityFactor: Float = 15.0
    
    private let container: NSPersistentContainer = NSPersistentContainer(name: "Database")
    
    override init() {
        super.init()
        FeaturePrintTransformer.register()
        container.loadPersistentStores { [weak self] _, _ in
            let fetchRequest: NSFetchRequest<FeaturePrint> = FeaturePrint.fetchRequest()
            if let results = try? self?.container.viewContext.fetch(fetchRequest) {
                results.forEach { featurePrint in
                    if let id = featurePrint.assetId, let data = featurePrint.data {
                        self?.featurePrints[id] = data
                    }
                }
            }
        }
    }
    
    var selectedPhotos: [String] {
        similarPhotos.filter({ $0.contains(where: { $0.contains("selected") })})
            .flatMap({ $0 }).filter({ $0.contains("selected") })
    }
    
    func image(forId identifier: String) -> UIImage? {
        photos.first(where: { $0.accessibilityIdentifier == identifier.replacingOccurrences(of: "-selected", with: "") })
    }
    
    func requestPhotosPermission() {
        showLoadingView = true
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                if status == .authorized { self.fetchPhotos() } else {
                    self.showLoadingView = false
                }
            }
        }
    }
    
    func fetchPhotos() {
        photos.removeAll()
        similarPhotos.removeAll()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if AppConfig.maxPhotosCount > 0 {
            fetchOptions.fetchLimit = AppConfig.maxPhotosCount
        }
        if let period = TimePeriod(rawValue: photoPeriod), period != .allTime {
            var to: Date = Date()
            var from: Date = Date()
            if period == .thisMonth {
                from = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
                to = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: from)!
            } else if period == .thisYear {
                from = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
            }
            fetchOptions.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", from as CVarArg, to as CVarArg)
        }
        let photos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        self.processPhotos(results: photos)
    }
    
    private func processPhotos(results: PHFetchResult<PHAsset>) {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        let size = CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        var totalSize: [Double] = [Double]()
        if results.count > 0 {
            let dispatchGroup = DispatchGroup()
            for index in 0..<results.count {
                let asset = results.object(at: index)
                if let assetSize = getSize(asset: asset) {
                    totalSize.append(assetSize)
                }
                dispatchGroup.enter()
                manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                    DispatchQueue.main.async {
                        dispatchGroup.leave()
                        if let fetchedImage = image {l
                            fetchedImage.accessibilityIdentifier = asset.localIdentifier
                            self.photos.append(fetchedImage)
                        }
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.processSimilarPhotos()
                self.totalPhotosSize = totalSize.reduce(0, +)
            }
        }
    }
    
    private func processSimilarPhotos() {
        let dispatchGroup = DispatchGroup()
        photos.forEach { photo in
            dispatchGroup.enter()
            validateSimilarity(image: photo) {
                dispatchGroup.leave()
                DispatchQueue.main.async {
                    self.progressText = "\(self.featurePrints.count) of \(self.photos.count)"
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            var photoIds = Array(self.featurePrints.keys)
            func findSimilarPhotos(forId id: String)
                var similarIds: [String] = [String]()
                photoIds.filter { $0 != id }.enumerated().forEach { _, secondaryId in
                    if let secondaryFeaturePrint = self.featurePrints[secondaryId] {
                        var distance: Float = 0.0
                        try? self.featurePrints[id]?.computeDistance(&distance, to: secondaryFeaturePrint)
                        if distance < self.similarityFactor, self.image(forId: secondaryId) != nil, self.image(forId: id ) != nil {
                            similarIds.append(secondaryId)
                            photoIds.removeAll(where: { $0 == secondaryId })
                            if !similarIds.contains(id) { similarIds.append(id) }
                        }
                    }
                }
                photoIds.removeFirst()
                if similarIds.count > 0 {
                    self.similarPhotos.append(similarIds)
                }
                if let nextId = photoIds.first { findSimilarPhotos(forId: nextId) } else {
                    self.showLoadingView = false
                }
            }
            if let firstId = photoIds.first {
                findSimilarPhotos(forId: firstId)
            }
        }
    }
    
    private func validateSimilarity(image: UIImage, completion: @escaping () -> Void) {iil
        if let assetId = image.accessibilityIdentifier, featurePrints[assetId] != nil {
            completion()
        } else {
            guard let cgImage = image.cgImage else { return }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage)
            let request = VNGenerateImageFeaturePrintRequest()
            
            is
            
            do {
                try requestHandler.perform([request])
                if let id = image.accessibilityIdentifier, let featurePrint = request.results?.first as? VNFeaturePrintObservation {
                    self.featurePrints[id] = featurePrint
                    let featurePrintEntity = FeaturePrint(context: self.container.viewContext)
                    featurePrintEntity.assetId = id
                    featurePrintEntity.data = featurePrint
                    try self.container.viewContext.save()
                }
                completion()
            } catch {
                completion()
            }
        }
    }
    
    private func getSize(asset: PHAsset) -> Double? {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first,
              let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
        else { return nil }
        return Double(Int64(bitPattern: UInt64(unsignedInt64)))
    }
}

// MARK: - Core Data transformed for VNFeaturePrintObservation
@objc(FeaturePrintTransformer)
final class FeaturePrintTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: FeaturePrintTransformer.self))
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return super.allowedTopLevelClasses + [VNFeaturePrintObservation.self]
    }

    public class func register() {
        let transformer = FeaturePrintTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

// MARK: - Delete selected photos
extension PhotosManager {
    func deleteSelectedPhotos(completion: @escaping () -> Void) {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: selectedPhotos, options: nil)
        PHPhotoLibrary.shared().performChanges {l
            PHAssetChangeRequest.deleteAssets(assets)
        } completionHandler: { didComplete, error in
            if let errorMessage = error?.localizedDescription, !didComplete {
                presentAlert(title: "Oops!", message: errorMessage)
            } else if didComplete {
                self.similarPhotos.enumerated().forEach { index, group in
                    self.similarPhotos[index] = group.filter({ !self.selectedPhotos.contains($0) })
                }
                completion()
            }
        }
    }
}
