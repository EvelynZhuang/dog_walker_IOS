//
//  showing.swift
//  itp342FinalProject
//
//  Created by admin on 2021/5/3.
// Yifan Zhuang zhuangyi@usc.edu


import UIKit
import Firebase
import MapKit
import CoreLocation
class showing: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    private let database = Database.database().reference()
    var currselectedPin:MKPlacemark? = nil
    var currentLocationEvents = [Dictionary<String, Any>]()
    var loginEmail = ""
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        fetchData()
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    //fetch data for showing all event at current address
    func fetchData() {
        currentLocationEvents.removeAll()
        let user = Auth.auth().currentUser
        if let user = user{
            print("This is login email \(loginEmail)")
            loginEmail = user.email ?? ""
            
        }
        let positionRef = database.child("event").child(String(currselectedPin?.name ?? "hi"))
        positionRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                // Go through every child
                for data in snapshot.children.allObjects as! [DataSnapshot] {
                    if let data = data.value as? [String: Any] {
                        let user = data["createUser"] as? String
                        let date = data["date"] as? String
                        let detail = data["detail"] as? String
                        let location = data["location"] as! String
                        let participant = data["participant"] as! NSMutableArray
                        
                        let dict = ["createUser": user as Any, "date":date ?? "", "detail":detail ?? "", "location":location, "participant":participant] as [String : Any]
                        self.currentLocationEvents.append(dict)
                    }
                }
                DispatchQueue.main.async {
                    print(self.currentLocationEvents)
                    self.tableView.reloadData()
                }
            }
        }
        
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentLocationEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewCell
        let userEmail = currentLocationEvents[indexPath.row]["createUser"] as! String?
        let date = currentLocationEvents[indexPath.row]["date"] as! String?
        let detail = currentLocationEvents[indexPath.row]["detail"] as! String?
        
        cell?.celldelegate = self
        cell?.index = indexPath
        cell?.hostUser = userEmail
        cell?.index = indexPath
        if(userEmail != loginEmail){
            cell?.notMine = true
            cell?.button.setTitle("Register", for: .normal)
        }
        else if (userEmail == loginEmail){
            cell?.notMine = false
            cell?.button.setTitle("Cancel", for: .normal)
        }
        
        
        cell?.textLabel?.text = "Hosted by \(userEmail ?? "no one")"
        cell?.detailTextLabel?.text = "\(date ?? "wrong time") Detail: \(detail ?? "No detail")"
        return cell!
    }
    
    
}


extension showing: tableView{
    
    
    //register in event or cancel this event
    func onClickCell(database: DatabaseReference, notMine: Bool, host: String?, index: IndexPath?) {
        //print("\(index)")
        let identifier = "\(currselectedPin?.name ?? "this is not a real place k?")"
        let endOfEmail = host!.firstIndex(of: ".")!
        let fakeEmail = String(host![..<endOfEmail])
        
        
        let register = UIAlertController(title: "This is a new event", message: "Do you want to register?", preferredStyle: .alert)
        let cancel = UIAlertController(title: "This is my event", message: "Do you want to cancel this event?", preferredStyle: .alert)
        
        let okRegister = UIAlertAction(title: "Yes sir", style: .default) { (UIAlertAction) in
            //find array, and replace it, and change
            for event in self.currentLocationEvents {
                print("current event host: \(event["createUser"]! as! String)")
                if((event["createUser"]! as! String) == host){
                    let participant = event["participant"] as! NSMutableArray
                    participant.add(self.loginEmail)
                    database.child("event").child(identifier).child(fakeEmail).updateChildValues(["participant" : participant])
                }
            }
            
            
            
        }
        
        let okCancel = UIAlertAction(title: "Yes sir", style: .default) { (UIAlertAction) in
            database.child("event").child(identifier).child(fakeEmail).removeValue()
            self.currentLocationEvents.remove(at: index!.row)
            DispatchQueue.main.async {
                print(self.currentLocationEvents)
                self.tableView.reloadData()
            }
        }
        
        
        
        let no = UIAlertAction(title: "Nope", style: .cancel, handler: nil)
        register.addAction(okRegister)
        register.addAction(no)
        cancel.addAction(okCancel)
        cancel.addAction(no)
        
        //add to database or delete from database
        if(notMine){//if register
            self.present(register, animated: true, completion: nil)
        }
        else{//if clicked cancel
            self.present(cancel, animated: true, completion: nil)
            
        }
        
    }
}
