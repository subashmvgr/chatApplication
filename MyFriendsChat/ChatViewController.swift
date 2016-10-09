//
//  ChatViewController.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/11/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class  ChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        guard let uid = FIRAuth.auth()?.currentUser?.uid, toId = user?.id else { return }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let msgID = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(msgID)
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else { return }

                self.messages.append(Message(dictionary: dict))
                
                self.timer?.invalidate()
                
                print("cancelled reload")
                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.handleReloadTableView), userInfo: nil, repeats: false)
                print("scheduled reload")
                
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
    }
    
    var timer: NSTimer?

    func handleReloadTableView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.reloadData()
            if self.messages.count > 0 {
                let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            }
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
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        collectionView?.keyboardDismissMode = .Interactive
        
        setupKeyboardObservers()
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.whiteColor()
        
        let attachmentIcon = UIButton()
        attachmentIcon.translatesAutoresizingMaskIntoConstraints = false
        attachmentIcon.setImage(UIImage(named: "attach"), forState: .Normal)
        attachmentIcon.addTarget(self, action: #selector(attachmentIconTapped), forControlEvents: .TouchUpInside)
        
        containerView.addSubview(attachmentIcon)
        
        attachmentIcon.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 8).active = true
        attachmentIcon.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        attachmentIcon.widthAnchor.constraintEqualToConstant(30).active = true
        attachmentIcon.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, constant: -16).active = true
        
        let sendButton = UIButton(type: .System)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), forControlEvents: .TouchUpInside)
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(60).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraintEqualToAnchor(attachmentIcon.rightAnchor, constant: 8).active = true
        self.inputTextField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        self.inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        self.inputTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        let sendBarBorderView = UIView()
        sendBarBorderView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        sendBarBorderView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(sendBarBorderView)
        
        sendBarBorderView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        sendBarBorderView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        sendBarBorderView.heightAnchor.constraintEqualToConstant(1).active = true
        sendBarBorderView.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    func setupKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if messages.count > 0 {
            let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
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
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimatedHeightForText(text).width + 25
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
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
        
        if let messageimgUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCache(messageimgUrl)
            cell.messageImageView.hidden = false
            cell.bubbleView.backgroundColor = UIColor.clearColor()
        } else {
            cell.messageImageView.hidden = true
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
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimatedHeightForText(text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(200 * imageHeight/imageWidth)
        }
        
        let width = UIScreen.mainScreen().bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func uploadToFirebase(image: UIImage) {
        let imageName = NSUUID().UUIDString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        if let uploadDate = UIImageJPEGRepresentation(image, 0.2) {
        ref.putData(uploadDate, metadata: nil, completion: { (metaData, err) in
            if err != nil {
                print ("failed to upload image:", err)
                return
            }
            
            if let imageURL = metaData?.downloadURL()?.absoluteString {
                self.handleSendImage(imageURL, image: image)
            }
        })
        }
    }
    
    func sendButtonTapped() {
        if let message = inputTextField.text where message != "" {
            let properties: [String: AnyObject] = ["text": message]
            sendMessageWithProperties(properties)
        }
    }
    
    private func handleSendImage(imageURL: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageWithProperties(properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        if let toId = user?.id, fromId = FIRAuth.auth()?.currentUser?.uid {
            var values: [String: AnyObject] = ["fromId": fromId, "toId": toId, "timestamp": timestamp]
            
            properties.forEach({values[$0] = $1})
            childRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err)
                    return
                }
                
                let senderMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
                let msgID = childRef.key
                
                senderMessagesRef.updateChildValues([msgID: 1])
                
                let receiverMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
                
                receiverMessageRef.updateChildValues([msgID: 1])
            })
        }
        inputTextField.text = ""
    }
    
    func attachmentIconTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
           uploadToFirebase(selectedImage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
    
    
    
    
}
