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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "MSG", style: .Plain, target: self, action: #selector(hanldeNewMessage))
        
        securityCheck()
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
        
        FIRDatabase.database().reference().child("users").child(uid).observeEventType(.Value, withBlock: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject], fName = dict["firstName"] as? String, lName = dict["lastName"] as? String {
                self.navigationItem.title = fName + " " + lName
            }
            }, withCancelBlock: nil)
        
    }
    
    func hanldeNewMessage() {
        let newMessageVC = NewMessageTableTableViewController()
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

}
