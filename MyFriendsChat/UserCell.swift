//
//  UserCell.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/11/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class  UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
           setupNameAndAvatar()
            detailTextLabel?.text = message?.text
            if let seconds = message?.timestamp?.doubleValue {
                let time = NSDate(timeIntervalSinceNow: seconds)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.stringFromDate(time)
            }
        }
    }
    
    private func setupNameAndAvatar() {
        
        if let id = message?.chatPartnerID() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dict["firstName"] as? String
                    if let imageUrl = dict["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCache(imageUrl)
                    }
                }
                }, withCancelBlock: nil)
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        label.text = "HH:MM:SS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let textLbl = textLabel, detailTextLbl = detailTextLabel {
            textLbl.frame = CGRectMake(64, textLbl.frame.origin.y - 2 , textLbl.frame.width, textLbl.frame.height)
            detailTextLbl.frame = CGRectMake(64, detailTextLbl.frame.origin.y + 2, detailTextLbl.frame.width, detailTextLbl.frame.height)
        }
        
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(48).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(48).active = true
        
        
        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8).active = true
        timeLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        timeLabel.widthAnchor.constraintEqualToConstant(70).active = true
        timeLabel.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
