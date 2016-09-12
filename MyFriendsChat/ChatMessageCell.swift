//
//  ChatMessageCell.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/10/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
   
    var textView: UITextView = {
        let tv = UITextView()
        tv.text = "sample text"
        tv.font = UIFont.systemFontOfSize(16)
        tv.backgroundColor = UIColor.clearColor()
        tv.textColor = UIColor.whiteColor()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    
    static let blueColor = UIColor(r: 0, g: 137, b: 239)
    
    var bubbleView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.masksToBounds = true
        vw.backgroundColor = blueColor
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    var imageIcon: UIImageView = {
       let imgVw = UIImageView()
        imgVw.image = UIImage(named: "chatImage")
        imgVw.layer.cornerRadius = 16
        imgVw.layer.masksToBounds = true
        imgVw.contentMode = .ScaleAspectFill
        imgVw.translatesAutoresizingMaskIntoConstraints = false
        return imgVw
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(imageIcon)
        
        imageIcon.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        imageIcon.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        imageIcon.widthAnchor.constraintEqualToConstant(32).active = true
        imageIcon.heightAnchor.constraintEqualToConstant(32).active = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant:  -8)
        bubbleViewRightAnchor?.active = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraintEqualToAnchor(imageIcon.rightAnchor, constant: 8)
        bubbleView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraintEqualToConstant(200)
        bubbleWidthAnchor?.active = true
        bubbleView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        
        textView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor, constant: 8).active = true
        textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        textView.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active = true
        textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
}
