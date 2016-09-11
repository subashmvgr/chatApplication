//
//  ChatViewController.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/11/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class  ChatViewController: UICollectionViewController, UITextFieldDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.firstName
        }
    }
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter Message.."
        tf.delegate = self
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        
        setupInputComponents()
    }
    
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        
        containerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        containerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        containerView.heightAnchor.constraintEqualToConstant(50).active = true
        
        
        let sendButton = UIButton(type: .System)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), forControlEvents: .TouchUpInside)
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(60).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 8).active = true
        inputTextField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        inputTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        let sendBarBorderView = UIView()
        sendBarBorderView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        sendBarBorderView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(sendBarBorderView)
        
        sendBarBorderView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        sendBarBorderView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        sendBarBorderView.heightAnchor.constraintEqualToConstant(1).active = true
        sendBarBorderView.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active = true
        
    }
    
    func sendButtonTapped() {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        if let message = inputTextField.text, toId = user?.id, fromId = FIRAuth.auth()?.currentUser?.uid {
        let values = ["text": message, "fromId": fromId, "toId": toId, "timestamp": timestamp]
        
        childRef.updateChildValues(values)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
    
    
}
