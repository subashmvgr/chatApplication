//
//  ChatViewController.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/11/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class  ChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.firstName
            observeMessages()
        }
    }
    
    var containerView: UIView = {
        let containerVw = UIView()
        containerVw.backgroundColor = UIColor.whiteColor()
        containerVw.translatesAutoresizingMaskIntoConstraints = false
        return containerVw
    }()
    
    
    var containerViewBottomConstraint: NSLayoutConstraint?
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let msgID = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(msgID)
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                let msg = Message()
                msg.setValuesForKeysWithDictionary(dict)
                if msg.chatPartnerID() == self.user?.id {
                self.messages.append(msg)
                
                    self.timer?.invalidate()
                    
                    print("cancelled reload")
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.handleReloadTableView), userInfo: nil, repeats: false)
                    print("scheduled reload")
                }
                
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
    }
    
    var timer: NSTimer?

    func handleReloadTableView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.reloadData()
            print("we reloaded collectionView")
        })
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
        collectionView?.alwaysBounceVertical = true
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: "cellID")
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        setupInputComponents()
        setupKeyboardObservers()
        
        
    }
    
    
    func setupKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        containerViewBottomConstraint?.constant = -keyboardFrame!.height
        
        UIView.animateWithDuration(keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        containerViewBottomConstraint?.constant = 0
        UIView.animateWithDuration(keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellID", forIndexPath: indexPath) as! ChatMessageCell

        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimatedHeightForText(message.text!).width + 25
        return cell
        
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let imgUrl = self.user?.profileImageUrl {
            cell.imageIcon.loadImageUsingCache(imgUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.whiteColor()
            cell.bubbleViewRightAnchor?.active = true
            cell.bubbleViewLeftAnchor?.active = false
            cell.imageIcon.hidden = true
        } else {
            cell.bubbleView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            cell.textView.textColor = UIColor.blackColor()
            cell.bubbleViewRightAnchor?.active = false
            cell.bubbleViewLeftAnchor?.active = true
            cell.imageIcon.hidden = false
            
            
        }
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func estimatedHeightForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        
        return NSString(string: text).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)], context: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var height: CGFloat = 80
        if let text = messages[indexPath.item].text {
            height = estimatedHeightForText(text).height + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    func setupInputComponents() {
        
        view.addSubview(containerView)
        
        
        containerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        containerViewBottomConstraint = containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        containerViewBottomConstraint?.active = true
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
            
            childRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err)
                    return
                }
                
                let senderMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
                let msgID = childRef.key
                
                senderMessagesRef.updateChildValues([msgID: 1])
                
                let receiverMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId)
                
                receiverMessageRef.updateChildValues([msgID: 1])
            })
        }
        
        inputTextField.text = ""
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
    
    
}
