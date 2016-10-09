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
        guard let email = emailTextField.text, password = passwordTextField.text where !password.isEmpty && !email.isEmpty  else {
            
            
            let alertController = UIAlertController(title: "Enter email/Password", message: "Please enter valid email and password to login", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.passwordTextField.text = ""
            }
            
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        self.setLoadingScreen()
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error != nil {
                self.loadingAlert.dismissViewControllerAnimated(true, completion: {
                    let alertController = UIAlertController(title: "invalid email or password", message: "Please enter valid email and password", preferredStyle: .Alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        self.passwordTextField.text = ""
                        self.repeatPasswordTextField.text = ""
                    }
                    
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
                return
            }
            self.dashBoardVC?.fetchUserAndSetTitle()
            self.loadingAlert.dismissViewControllerAnimated(true, completion: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func handleSignUp() {
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
        self.setLoadingScreen()
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password , completion: { (user: FIRUser?, error) in
            if error != nil {
                self.loadingAlert.dismissViewControllerAnimated(true, completion: {
                    let alertController = UIAlertController(title: "inavalid email or password", message: "Please enter valid email and password", preferredStyle: .Alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        self.passwordTextField.text = ""
                        self.repeatPasswordTextField.text = ""
                    }
                    
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("profileImages").child("\(imageName).JPEG")
            
            
            if let profImage = self.profileImageView.image, uploadData = UIImageJPEGRepresentation(profImage, 0.1) {
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
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users").child(uid)
        
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err)
                return
            }

            let user = User()
            user.setValuesForKeysWithDictionary(values)
            self.dashBoardVC?.setupNavBarFromUser(user)
            self.loadingAlert.dismissViewControllerAnimated(true, completion: nil)
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
        loadingAlert = UIAlertController(title: nil, message: "Please Wait...", preferredStyle: .Alert)
        loadingAlert.view.tintColor = UIColor.blackColor()
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating()
        
        loadingAlert.view.addSubview(loadingIndicator)
        presentViewController(loadingAlert, animated: true, completion: nil)
    }
 
}
