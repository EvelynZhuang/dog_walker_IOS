//
//  ViewController.swift
//  itp342FinalProject
//
//  Created by admin on 2021/4/25.
// Yifan Zhuang zhuangyi@usc.edu

import UIKit
import FirebaseDatabase
import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInDelegate {
    
    private let database = Database.database().reference()
    
    
    
    @IBOutlet weak var SignInLabel: UILabel! //actually sign up label
    @IBOutlet weak var SignUpEmail: UITextField!
    @IBOutlet weak var SignUpPwd: UITextField!
    @IBOutlet weak var SignUpName: UITextField!
    @IBOutlet weak var SignUpButton: UIButton!
    
    @IBOutlet weak var SignInButton: UIButton!
    
    @IBOutlet var SignInWithGoogle: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        SignUpButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    //tap button to sign in
    @objc private func didTapButton(){
        //alert action
        let failAlert = UIAlertController(title: "Something went wrong when signning in", message: "You probably have wrongly formatted email, too-short password, or this email has already be taken.", preferredStyle: .alert)
    
        let nameCheckAlert = UIAlertController(title: "Can not be null", message: "Hey you, complete the box first", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK fine", style: .default, handler: nil)
        failAlert.addAction(ok)
        nameCheckAlert.addAction(ok)
        //alert ation
        
        if((SignUpName.text == nil || SignUpName.text == "")||(SignUpPwd.text == nil || SignUpPwd.text == "")||(SignUpEmail.text == nil || SignUpEmail.text == "")){
            self.present(nameCheckAlert, animated: true, completion: nil)
        }
        
        
        guard let email = SignUpEmail.text, !email.isEmpty,
        let password = SignUpPwd.text, !password.isEmpty else{
            print("missing field data")
            return
        }
        
        //sign up with current info
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            authResult, error in
            if(error != nil){
                self.present(failAlert, animated: true, completion: nil)
                print(error)
                return
            }
            else{
                let object: [String: Any] = [
                    
                    "email": email as NSObject,
                    "name": self.SignUpName.text!,
                    "profile": "There's nothing here. This user is lazy."
                ]
                
                let endOfEmail = email.firstIndex(of: ".")!
                let fakeEmail = email[..<endOfEmail]

                self.database.child("users").child(String(fakeEmail)).setValue(object)
                
                self.performSegue(withIdentifier: "signUp", sender: self)
            }
            
        })
        
        
        
    }
    
    //sign in with google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let authentication = user.authentication {
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential, completion: { (user, error) -> Void in
                    if error != nil {
                        print("Problem at signing in with google with error : \(error)")
                    } else if error == nil {
                        print("signed in")
                        
                        self.performSegue(withIdentifier: "signUp", sender: self)
                    }
                })
            }

    }

    
    

}

