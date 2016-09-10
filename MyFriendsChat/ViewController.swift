//
//  ViewController.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/1/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        
    }

    func handleLogout() {
        let LoginVC = LoginViewController()
        presentViewController(LoginVC, animated: true, completion: nil)
    }

}
