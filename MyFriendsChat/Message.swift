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
    
    func chatPartnerID() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
