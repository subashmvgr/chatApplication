//
//  Extensions.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/10/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit

let imageCache = NSCache()

extension UIImageView {
    
    func loadImageUsingCache(urlString: String) {
        self.image = nil
        
        if let existingImage = imageCache.objectForKey(urlString) as? UIImage {
            self.image = existingImage
            return
        }
        
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, err) in
            if err != nil {
                print(err)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                
                if let downloadedData = data, downloadedImage = UIImage(data: downloadedData) {
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    self.image = downloadedImage
                }
            })
        }).resume()
    }
    
}
