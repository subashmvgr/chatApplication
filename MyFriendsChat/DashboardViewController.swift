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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        }
        
        
    }

    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let LoginVC = LoginViewController()
        presentViewController(LoginVC, animated: true, completion: nil)
    }

}
