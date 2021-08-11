//
//  profilePage.swift
//  itp342FinalProject
//
//  Created by admin on 2021/4/26.
// Yifan Zhuang zhuangyi@usc.edu

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
class profilePage: UIViewController {

    private let database = Database.database().reference()

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UILabel!
    
    var email:String?
    var photoURL:URL?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let user = Auth.auth().currentUser
        if let user = user{
            email = user.email
            photoURL = user.photoURL
            
        }
        if email != nil || photoURL != nil{
            name.text = email

        }

        let endOfEmail = email!.firstIndex(of: ".")!
        let fakeEmail = email![..<endOfEmail]
        
        database.child("users").child(String(fakeEmail)).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else{
                return
            }
            self.profile.text = value["profile"] as? String
            self.name.text = value["name"] as? String
        }
    }
    
    

   
    
    //log out button
    @IBAction func logOutButton(_ sender: Any) {
        do{
            //if sign in type is email
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "signOut", sender: self)
        }
        catch{
            print("An error occured")
        }
    }

}
