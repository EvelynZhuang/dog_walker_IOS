//
//  SignInPage.swift
//  itp342FinalProject
//
//  Created by admin on 2021/4/25.
// Yifan Zhuang zhuangyi@usc.edu


import UIKit
import Firebase

class SignInPage: UIViewController {

   
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var pwdTextfield: UITextField!
    @IBOutlet weak var emailTextfiled: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        pwdTextfield.isSecureTextEntry = true
        alertLabel.isHidden = true
       
    }
    

    //sign in button
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextfiled.text, !email.isEmpty,
        let password = pwdTextfield.text, !password.isEmpty else{
            print("missing field data")
            return
        }
        
        //sign up with current info
        Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] user, error in
            guard let strongSelf = self else { return }
            if(error != nil){
                strongSelf.alertLabel.isHidden = false
                strongSelf.alertLabel.text = "Error, check username and password"
                return
            }
            else{
                strongSelf.performSegue(withIdentifier: "signIn", sender: self)
            }
            
        })
    }

}
