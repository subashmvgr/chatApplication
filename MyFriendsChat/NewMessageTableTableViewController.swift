//
//  NewMessageTableTableViewController.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/10/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableTableViewController: UITableViewController {
    var users = [User]()
    let cellId = "CellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.firstName! + " " + user.lastName!
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
}

class  UserCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
