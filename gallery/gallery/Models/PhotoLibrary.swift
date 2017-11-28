//
//  PhotoLibrary.swift
//  gallery
//
//  Created by 진형탁 on 2017. 11. 28..
//  Copyright © 2017년 njir. All rights reserved.
//

import Foundation
import Photos

enum ViewMode {
    case thumbnail
    case full
}

class PhotoLibrary {
    fileprivate var imgManager: PHImageManager
    fileprivate var requestOptions: PHImageRequestOptions
    fileprivate var fetchOptions: PHFetchOptions
    fileprivate var fetchResult: PHFetchResult<PHAsset>
    
    init () {
        imgManager = PHImageManager.default()
        requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                             PHAssetMediaType.image.rawValue,
                                             PHAssetMediaType.video.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
    }
    
    var count: Int {
        return fetchResult.count
    }
    
    // MARK:- Function
    
    func getAsset(at index: Int) -> PHAsset? {
        guard index < fetchResult.count else { return nil }
        return fetchResult.object(at: index) as PHAsset
    }
    
    func setLibrary(mode selectMode: ViewMode = .full, at index: Int, completion block: @escaping (UIImage?, Bool)->()) {
        if index < fetchResult.count  {
            var size: CGSize = UIScreen.main.bounds.size
            if selectMode == .thumbnail {
                // As the size increases, there is an error that the image in the collectionview is not shown.
                size = CGSize(width: 100, height: 100)
            }
            imgManager.requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, phAssetForVideo) in
                // check Photo or Video
                let asset = self.fetchResult.object(at: index)
                var isVideo: Bool = false
                if asset.mediaType == .video {
                    isVideo = true
                }
                block(image, isVideo)
            }
        } else {
            block(nil, false)
        }
    }
    
    func getPhoto(at index: Int) -> UIImage {
        var result = UIImage()
        imgManager.requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, _) in
            if let image = image {
                result = image
            }
        }
        return result
    }
   
}
