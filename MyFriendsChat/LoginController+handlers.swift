//
//  LoginController+handlers.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/10/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleLoginSignUp() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleSignUp()
        }
    }
    
    func handleLogin() {
        self.setLoadingScreen()
        guard let email = emailTextField.text, password = passwordTextField.text where !password.isEmpty && !email.isEmpty  else {
            
            
            let alertController = UIAlertController(title: "Enter email/Password", message: "Please enter valid email and password to login", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.passwordTextField.text = ""
            }
            
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error != nil {
                let alertController = UIAlertController(title: "inavalid email or password", message: "Please enter valid email and password", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.passwordTextField.text = ""
                    self.repeatPasswordTextField.text = ""
                }
                
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            self.removeLoadingScreen()
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func handleSignUp() {
        self.setLoadingScreen()
        guard let email = emailTextField.text, password = passwordTextField.text, firstName = firstNameField.text, lastName = lastNameField.text  where passwordTextField.text == repeatPasswordTextField.text && !password.isEmpty && !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty  else {
            
            
            let alertController = UIAlertController(title: "Invalid details", message: "Please enter valid name, email and password to register", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.passwordTextField.text = ""
                self.repeatPasswordTextField.text = ""
            }
            
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password , completion: { (user: FIRUser?, error) in
            if error != nil {
                let alertController = UIAlertController(title: "inavalid email or password", message: "Please enter valid email and password", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.passwordTextField.text = ""
                    self.repeatPasswordTextField.text = ""
                }
                
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("profileImages").child(imageName)
            
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
             storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil {
                    print(error)
                    return
                }
                if let imageUrl = metaData?.downloadURL()?.absoluteString {
                let values = ["firstName": firstName, "lastName": lastName, "email": email, "profileImageUrl": imageUrl]
                self.registerUserIntoDatabase(uid, values: values)
                }
             })
            }
            
            
        })
    }
    
    
    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().referenceFromURL("https://myfriendschat-9f294.firebaseio.com/")
        let userRef = ref.child("users").child(uid)
        
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err)
                return
            }
            self.removeLoadingScreen()
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func handleloginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegmentAtIndex(loginRegisterSegmentedControl.selectedSegmentIndex)
        signUpButton.setTitle(title, forState: .Normal)
        
        
        profileImageView.userInteractionEnabled = loginRegisterSegmentedControl.selectedSegmentIndex == 1
        //change height of inputcontainer
        containerHeightConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        
        firstNameHeightConstraint?.active = false
        emailHeightConstraint?.active = false
        passwordHeightConstraint?.active = false
        passwordWidthConstraint?.active = false
        repeastpasswordWidthConstraint?.active = false
        
        firstNameHeightConstraint = firstNameField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        emailHeightConstraint = emailTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordHeightConstraint =  passwordTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordWidthConstraint = passwordTextField.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1 : 1/2, constant: -24)
        repeastpasswordWidthConstraint = repeatPasswordTextField.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/2, constant: -24)
        passwordDividerView.hidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        
        repeastpasswordWidthConstraint?.active = true
        passwordWidthConstraint?.active = true
        passwordHeightConstraint?.active = true
        emailHeightConstraint?.active = true
        firstNameHeightConstraint?.active = true
    }
    
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
    
        if let selectedImage = selectedImageFromPicker {
           profileImageView.image = selectedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func setLoadingScreen() {
        view.addSubview(spinner)
        spinner.startAnimating()
        spinner.hidden = false
        spinner.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        spinner.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        spinner.widthAnchor.constraintEqualToConstant(30).active = true
        spinner.heightAnchor.constraintEqualToConstant(30).active = true
    }
    
    private func removeLoadingScreen() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
 
}
