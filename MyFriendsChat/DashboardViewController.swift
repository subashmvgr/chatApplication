//
//  ViewController.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/1/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class DashboardViewController: UITableViewController {

    var messages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "MSG", style: .Plain, target: self, action: #selector(hanldeNewMessage))
        
        securityCheck()
        observeMessages()
    }
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                let message = Message()
                message.setValuesForKeysWithDictionary(dict)
                self.messages.append(message)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            }, withCancelBlock: nil)
    }
    
    func securityCheck() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            fetchUserAndSetTitle()
        }
    }

    
    func fetchUserAndSetTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let user = User()
            if let dict = snapshot.value as? [String: AnyObject] {
                user.setValuesForKeysWithDictionary(dict)
            }
            
            self.setupNavBarFromUser(user)
            }, withCancelBlock: nil)
        
    }
    
    func setupNavBarFromUser(user: User) {
        
        let titleView = UIView()
        titleView.frame = CGRectMake(0, 0, 100, 40)
        
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let fName = user.firstName, lName = user.lastName {
            titleLabel.text = fName + " " + lName
        }
        
        let titleImageView = UIImageView()
        titleImageView.contentMode = .ScaleToFill
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleImageView.layer.cornerRadius = 20
        titleImageView.layer.masksToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            titleImageView.loadImageUsingCache(profileImageUrl)
        }
        
        containerView.addSubview(titleImageView)
        containerView.addSubview(titleLabel)
        
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true
        
        titleImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        titleImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        titleImageView.widthAnchor.constraintEqualToConstant(40).active = true
        titleImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        titleLabel.leftAnchor.constraintEqualToAnchor(titleImageView.rightAnchor, constant: 8).active = true
        titleLabel.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        titleLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        titleLabel.heightAnchor.constraintEqualToAnchor(titleImageView.heightAnchor).active = true
        
         self.navigationItem.titleView = titleView
        
    }
    
    func showChatViewForUser(user: User) {
        let chatVC = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatVC.user = user
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func hanldeNewMessage() {
        let newMessageVC = NewMessageTableViewController()
        newMessageVC.dashVC = self
        let navController = UINavigationController(rootViewController: newMessageVC)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let LoginVC = LoginViewController()
        LoginVC.dashBoardVC = self
        presentViewController(LoginVC, animated: true, completion: nil)
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cellID")
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.toId
        cell.detailTextLabel?.text = message.text
        return cell
    }
}
