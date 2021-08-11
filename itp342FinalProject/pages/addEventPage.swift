//
//  addEvent.swift
//  itp342FinalProject
//
//  Created by admin on 2021/4/28.
// Yifan Zhuang zhuangyi@usc.edu


import UIKit
import FirebaseDatabase
import Firebase
import MapKit
import CoreLocation



class addEvent: UIViewController, UITextViewDelegate {
    
    private let database = Database.database().reference()
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descrip: UITextView!
    @IBOutlet weak var timedisplay: UILabel!
    
    //current location
    var currselectedPin:MKPlacemark? = nil
    var warningTime = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        descrip.delegate = self
        self.hideKeyboardWhenTappedAround()
        descrip.clipsToBounds = true
        descrip.layer.cornerRadius = 10.0
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        
    }
    
    
    
    
    //add an event
    @IBAction func addEventButton(_ sender: Any) {
        //if nil in textview, add an alert
        
        
        if descrip.text.isEmpty && warningTime == 0{
            let textCheck = UIAlertController(title: "Are you sure?", message: "Do you want to add no description my friend?", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK fine", style: .default) { (UIAlertAction) in
                self.warningTime += 1
            }
            textCheck.addAction(ok)
            self.present(textCheck, animated: true, completion: nil)

        }
        
        
        var date:String
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        date = formatter.string(from: datePicker.date)
        
        let long = currselectedPin!.coordinate.longitude
        let lat = currselectedPin!.coordinate.latitude
        let coordinates : NSArray = [long , lat]
        //add to database
        let user = Auth.auth().currentUser
        let participant : NSMutableArray = [String(user!.email!)]
        let object: [String: Any] = [
            "createUser": user!.email!, //save who created it
            "date": date, //what time is it, last how long
            "location": (currselectedPin?.name ?? "") as String,
            "TwoDLocation": coordinates as NSArray,
            "detail": descrip.text ?? "I'm lazy.",
            
            "participant": participant
        ]

        
        
        
        let identifier = "\(currselectedPin?.name ?? "this is not a real place k?")"
        timedisplay.text = identifier
        
        //use email as child
        let endOfEmail = user!.email!.firstIndex(of: ".")!
        let fakeEmail = user!.email![..<endOfEmail]
        
        print(identifier)
        //might crash
        self.database.child("event").child(identifier).child(String(fakeEmail)).setValue(object)
        
        
        
        if(warningTime > 0) || !descrip.text.isEmpty{
            self.dismiss(animated: true, completion: nil);
        }
        
    }
    
    

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
