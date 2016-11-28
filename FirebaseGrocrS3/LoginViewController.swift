//
//  LoginViewController.swift
//  FirebaseGrocrS3
//
//  Created by Patrick Pahl on 10/23/16.
//  Copyright © 2016 Patrick Pahl. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let loginToListSegue = "LoginToListSegue"
    
    // MARK: Outlets
    @IBOutlet var loginEmailTextField: UITextField?
    @IBOutlet var loginPasswordTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase has observers that allow you to monitor a user’s authentication state. This is a great place to perform a segue.
        FIRAuth.auth()?.addStateDidChangeListener() { auth, user in
            //Create an authentication observer
            if user != nil {
                self.performSegue(withIdentifier: self.loginToListSegue, sender: nil)
                //On successful authentication, perform the segue
            }
        }
    }
    
    // MARK: Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let loginEmailTextFieldText = loginEmailTextField?.text else { return }
        guard let loginPasswordTextFieldText = loginPasswordTextField?.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: loginEmailTextFieldText, password: loginPasswordTextFieldText)
        //This code will authenticate the user when they attempt to log in by tapping the Login button.
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Register", message: "Register", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            
            let emailField = alert.textFields?[0]
            let passwordField = alert.textFields?[1]
            //Get the email and password as supplied by the user from the alert controller.
            
            guard let emailFieldText = emailField?.text else { return }
            guard let passwordFieldtext = passwordField?.text else { return }
            
            FIRAuth.auth()?.createUser(withEmail: emailFieldText, password: passwordFieldtext) { user, error in
                //Call createUser on the default Firebase auth object passing the email and password.
                if error == nil {
                    guard let loginEmailTextFieldText = self.loginEmailTextField?.text else { return }
                    guard let loginPasswordTextFieldText = self.loginPasswordTextField?.text else { return }
                    
                    FIRAuth.auth()?.signIn(withEmail: loginEmailTextFieldText, password: loginPasswordTextFieldText)
                    //If there are no errors, the user account has been created. However, you still need to authenticate this new user, so call signIn, again passing in the supplied email and password.
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginEmailTextField {
            loginPasswordTextField?.becomeFirstResponder()
        }
        if textField == loginPasswordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
