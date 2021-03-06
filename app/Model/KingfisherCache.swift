//
//  KingfisherCache.swift
//  Sample
//
//  Created by Mats Becker on 10/3/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class KingfisherCache: NSObject {
  static let sharedManager = KingfisherCache()
}

extension KingfisherCache: ASImageDownloaderProtocol {
  /**
   @abstract Cancels an image download.
   @param downloadIdentifier The opaque download identifier object returned from 
   `downloadImageWithURL:callbackQueue:downloadProgressBlock:completion:`.
   @discussion This method has no effect if `downloadIdentifier` is nil.
   */
  public func cancelImageDownload(forIdentifier downloadIdentifier: Any) {
    
    if let request: RetrieveImageTask = downloadIdentifier as? RetrieveImageTask {
      request.cancel()
    }
  }

  public func downloadImage(with URL: URL, callbackQueue: DispatchQueue, downloadProgress: ASImageDownloaderProgress?, completion: @escaping ASImageDownloaderCompletion) -> Any? {
    
    let identifier: String = URL.lastPathComponent
    let resource = ImageResource(downloadURL: URL, cacheKey: identifier)
    
    let request = KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
      
      guard let downloadedImage = image else {
//        completion(nil, error, nil)
        completion(image, error, nil)
        return
      }
      // FIX: Why do we must cache the image maually?
      ImageCache.default.store(downloadedImage, forKey: identifier)
      completion(downloadedImage, nil, nil)
      
      })
    return request
  }
  
}

extension KingfisherCache: ASImageCacheProtocol {

  
  public func cachedImage(with URL: URL, callbackQueue: DispatchQueue, completion: @escaping ASImageCacherCompletion) {
    let identifier: String = URL.lastPathComponent
    
    ImageCache.default.retrieveImage(forKey: identifier, options: nil) {
      image, cacheType in
      if let image = image {
        completion(image.asdk_image())
        return
      } else {
        completion(nil)
      }
    }
    

  }
  
  
  
}
