//
//  LoginViewController.swift
//  MyFriendsChat
//
//  Created by Subash Dantuluri on 9/1/16.
//  Copyright © 2016 Subash Dantuluri. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    var containerView: UIView = {
        let View = UIView()
        View.backgroundColor = UIColor.whiteColor()
        View.layer.cornerRadius = 5
        View.layer.masksToBounds = true
        View.translatesAutoresizingMaskIntoConstraints = false
        return View
    }()
    
    lazy var signUpButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(r: 70, g: 140, b: 210)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign up", forState: .Normal)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        
        btn.addTarget(self, action: #selector(handleSignUp), forControlEvents: .TouchUpInside)
        return btn
    }()
    
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
            let ref = FIRDatabase.database().referenceFromURL("https://myfriendschat-9f294.firebaseio.com/")
            let userRef = ref.child("users").child(uid)
            let values = ["firstName": firstName, "lastName": lastName, "email": email ]
            
            userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err)
                    return
                }
                print ("saved user succesfully into firebase db")
                self.signUpButton.setTitle("Registered", forState: .Normal)
            })
        })
    }
    
    var firstNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "First Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var lastNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Last Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var nameSeperatorView: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor.lightGrayColor()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    var nameDividerView: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor.lightGrayColor()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var emailSeperatorView: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor.lightGrayColor()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.secureTextEntry = true
        return tf
    }()
    
    var repeatPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Re-enter Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.secureTextEntry = true
        return tf
    }()
    
    var passwordDividerView: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor.lightGrayColor()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 90, g: 90, b: 90)
        
        view.addSubview(containerView)
        view.addSubview(signUpButton)
        
        setupContainerView()
        setupSignUpButton()
    }
    
    func setupContainerView() {
        containerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: -40).active = true
        containerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -24).active = true
        containerView.heightAnchor.constraintEqualToConstant(180).active = true
        
        containerView.addSubview(firstNameField)
        containerView.addSubview(lastNameField)
        containerView.addSubview(nameSeperatorView)
        containerView.addSubview(nameDividerView)
        containerView.addSubview(emailTextField)
        containerView.addSubview(emailSeperatorView)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(repeatPasswordTextField)
        containerView.addSubview(passwordDividerView)
        
        firstNameField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 12).active = true
        firstNameField.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        firstNameField.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor, multiplier: 1/2, constant: -24).active = true
        firstNameField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, multiplier: 1/3).active = true
        
        lastNameField.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor, constant: -12).active = true
        lastNameField.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        lastNameField.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor, multiplier: 1/2, constant: -24).active = true
        lastNameField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, multiplier: 1/3).active = true
        
        nameSeperatorView.centerXAnchor.constraintEqualToAnchor(containerView.centerXAnchor).active = true
        nameSeperatorView.topAnchor.constraintEqualToAnchor(lastNameField.bottomAnchor).active = true
        nameSeperatorView.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active = true
        nameSeperatorView.heightAnchor.constraintEqualToConstant(1).active = true
        
        nameDividerView.centerXAnchor.constraintEqualToAnchor(containerView.centerXAnchor).active = true
        nameDividerView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        nameDividerView.widthAnchor.constraintEqualToConstant(1).active = true
        nameDividerView.heightAnchor.constraintEqualToAnchor(lastNameField.heightAnchor).active = true
        
        emailTextField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 12).active = true
        emailTextField.topAnchor.constraintEqualToAnchor(lastNameField.bottomAnchor).active = true
        emailTextField.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor, constant: -24).active = true
        emailTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, multiplier: 1/3).active = true
        
        emailSeperatorView.centerXAnchor.constraintEqualToAnchor(containerView.centerXAnchor).active = true
        emailSeperatorView.topAnchor.constraintEqualToAnchor(emailTextField.bottomAnchor).active = true
        emailSeperatorView.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active = true
        emailSeperatorView.heightAnchor.constraintEqualToConstant(1).active = true
        
        passwordTextField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 12).active = true
        passwordTextField.topAnchor.constraintEqualToAnchor(emailTextField.bottomAnchor).active = true
        passwordTextField.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor, constant: -24).active = true
        passwordTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, multiplier: 1/3).active = true
        
        repeatPasswordTextField.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor, constant: -12).active = true
        repeatPasswordTextField.topAnchor.constraintEqualToAnchor(emailTextField.bottomAnchor).active = true
        repeatPasswordTextField.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor, multiplier: 1/2, constant: -24).active = true
        repeatPasswordTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, multiplier: 1/3).active = true
        
        passwordDividerView.centerXAnchor.constraintEqualToAnchor(containerView.centerXAnchor).active = true
        passwordDividerView.topAnchor.constraintEqualToAnchor(repeatPasswordTextField.topAnchor).active = true
        passwordDividerView.widthAnchor.constraintEqualToConstant(1).active = true
        passwordDividerView.heightAnchor.constraintEqualToAnchor(repeatPasswordTextField.heightAnchor).active = true
    }
    
    func setupSignUpButton() {
        signUpButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        signUpButton.topAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: 12).active = true
        signUpButton.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor, multiplier: 2/3).active = true
        signUpButton.heightAnchor.constraintEqualToConstant(50).active = true
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green:  g/255, blue: b/255, alpha: 1)
    }
}