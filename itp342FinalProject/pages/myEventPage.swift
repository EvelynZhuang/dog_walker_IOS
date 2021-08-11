//
//  myEventPage.swift
//  itp342FinalProject
//
//  Created by admin on 2021/5/3.
// Yifan Zhuang zhuangyi@usc.edu


import UIKit
import Firebase
import EventKit
import EventKitUI
class myEventPage: UIViewController, UITableViewDelegate, UITableViewDataSource, EKEventEditViewDelegate  {
    
    
    
    let store = EKEventStore()
    
    @IBAction func freshTapped(_ sender: Any) {
        fetchData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    private let database = Database.database().reference()
    var currentLocationEvents = [Dictionary<String, Any>]()
    var currUser = ""
    var currentSelectRow = -1
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        fetchData()
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchData()
        tableView.reloadData()
    }
    
    
    //fetch data for event title and time
    func fetchData(){
        currentLocationEvents.removeAll()
        
        let user = Auth.auth().currentUser
        if let user = user{
            currUser = user.email ?? ""
            
        }
        
        
        let positionRef = database.child("event")
        positionRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                // Go through every child
                for data in snapshot.children.allObjects as! [DataSnapshot] { //all locations
                    for eachLoc in data.children.allObjects as! [DataSnapshot]{
                        if let eachLoc = eachLoc.value as? [String: Any] {
                            if let participant = eachLoc["participant"] as? NSMutableArray{
                                if participant.contains(self.currUser){
                                    let user = eachLoc["createUser"] as? String
                                    let date = eachLoc["date"] as? String
                                    let detail = eachLoc["detail"] as? String
                                    let location = eachLoc["location"] as! String
                                    let dict = ["createUser": user as Any, "date":date ?? "", "detail":detail ?? "", "location":location] as [String : Any]
                                    
                                    print(dict)
                                    self.currentLocationEvents.append(dict)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentLocationEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? nil
        
        let userEmail = currentLocationEvents[indexPath.row]["createUser"] as! String
        let date = currentLocationEvents[indexPath.row]["date"] as! String
        let detail = currentLocationEvents[indexPath.row]["detail"] as! String
        let location = currentLocationEvents[indexPath.row]["location"] as! String
        
        
        cell?.textLabel?.text = "\(location), hosted by \(userEmail)"
        cell?.detailTextLabel?.text = "\(date) Detail: \(detail)"
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //request calendar
        currentSelectRow = indexPath.row
        //performSegue(withIdentifier: "showEventKit", sender: self)
        store.requestAccess(to: .event) { (success, error) in
            if success, error == nil{
                DispatchQueue.main.async {
                    var date: Date
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .medium
                    
                    date = formatter.date(from: self.currentLocationEvents[self.currentSelectRow]["date"] as! String)!
                    
                    let newEvent = EKEvent(eventStore: self.store)
                    newEvent.title = self.currentLocationEvents[self.currentSelectRow]["location"] as? String
                    newEvent.startDate = date
                    newEvent.endDate = date.addingTimeInterval(60)
                    print(self.currentLocationEvents[self.currentSelectRow]["date"]!)
                    
                    let vc = EKEventEditViewController()
                    vc.eventStore = self.store
                    vc.editViewDelegate = self
                    
                    vc.event = newEvent
                    self.present(vc, animated: true, completion: nil)
                    
                    
                }
            }
            
        }
    }

    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
