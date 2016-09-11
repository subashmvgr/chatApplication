//
//  NewMessageTableTableViewController.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/10/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {
    var users = [User]()
    let cellId = "CellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUsers()
    }
    
    func fetchUsers() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeysWithDictionary(dict)
                self.users.append(user)
                //this will crash because of background thread, so lets use dispatch_async to fix
               dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
               })
            }
            }, withCancelBlock: nil)
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        let user = users[indexPath.row]
        if let fName = user.firstName, lName = user.lastName {
        cell.textLabel?.text = fName + " " + lName
        }
        cell.detailTextLabel?.text = user.email
        if let profileImageUrl = user.profileImageUrl {
          cell.profileImageView.loadImageUsingCache(profileImageUrl)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    
    var dashVC: DashboardViewController?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true) {
            let user = self.users[indexPath.row]
            self.dashVC?.showChatViewForUser(user)
        }
    }
    
}

class  UserCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
        
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
        
        
        //ios 9 constraints
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(48).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(48).active = true
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
