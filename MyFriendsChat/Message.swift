//
//  Message.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/11/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var toId: String?
    var fromId: String?
    var timestamp: NSNumber?
    var text: String?
    
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerID() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
    }
}
