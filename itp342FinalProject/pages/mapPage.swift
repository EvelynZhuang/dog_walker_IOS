//
//  mapPage.swift
//  itp342FinalProject
//
//  Created by admin on 2021/4/26.
// Yifan Zhuang zhuangyi@usc.edu

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import GoogleSignIn

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class mapPage: UIViewController, MKMapViewDelegate {
    
    let location = CLLocationCoordinate2D.init(latitude: 37.7862, longitude: -122.4045)

    
    private let database = Database.database().reference()
    @IBOutlet weak var mapView: MKMapView!
    var selectedPin:MKPlacemark? = nil
    var resultSearchController:UISearchController? = nil


    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        
        //new code
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

        mapView.delegate = self
        
        //load all map data from firebase database
        //allEvent.removeAll()
        fetchData()
        


    }
    
    
    //fetch data to display
    func fetchData(){
        let positionRef = database.child("event")
        positionRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot] { //all locations
                    var alreadyGrabbedLoc = false
                    var TwoDlocation : NSArray
                    var location : String
                    for eachLoc in data.children.allObjects as! [DataSnapshot]{
                        if let eachLoc = eachLoc.value as? [String: Any] {
                            if alreadyGrabbedLoc{
                                continue
                            }
                            TwoDlocation = eachLoc["TwoDLocation"] as! NSArray
                            location = eachLoc["location"] as! String? ?? "no place"
                            
                            
                            let annot = MKPointAnnotation()
                            
                            annot.title = location
                            let twodLoc = CLLocationCoordinate2D(latitude: TwoDlocation[0] as! Double, longitude: TwoDlocation[1] as! Double)
                            
                            annot.coordinate = twodLoc
                            self.mapView.addAnnotation(annot)
                            alreadyGrabbedLoc = true
                        }
                    }
                    
                    
                }
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else{
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.isEnabled = true
            annotationView?.canShowCallout = true
            
            
            //add two button for show all the events and add events
            let showbtn = UIButton(type: .detailDisclosure)
            let addbtn = UIButton(type: .contactAdd)
            annotationView?.leftCalloutAccessoryView = addbtn
            annotationView?.rightCalloutAccessoryView = showbtn
            addbtn.accessibilityIdentifier = "add"
            showbtn.accessibilityIdentifier = "show"
            
        }
        else{
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = UIImage(named: "paw")
        
        return annotationView
        
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if(control == view.leftCalloutAccessoryView){
            performSegue(withIdentifier: "addEvent", sender: self)
        }
        else{
            //change
            performSegue(withIdentifier: "show", sender: self)
        }
        
    }
    

    func setupLocationManager(){
        locationManager.delegate=self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation(){//i want center view on union square
        
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
        
        
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
        
        
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else{
            //show alert turn on
        }
    }
    
    func checkLocationAuthorization(){
        switch locationManager.authorizationStatus{
        case .restricted:
            //show an alert letting them know whats up
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            //show alert
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
            
        @unknown default:
            fatalError()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addEvent"{
            if let addEventController = segue.destination as? addEvent{
                addEventController.currselectedPin = selectedPin
            }
        }
        
        //change
        if segue.identifier == "show"{
            if let showEventController = segue.destination as? showing{
                showEventController.currselectedPin = selectedPin
                
            }
        }
    }
    
   

}


extension mapPage: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update location when walking around but i dont need it right now
        
        guard let location = locations.last else{return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //will back
    }
}

extension mapPage: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        
        
        
        //add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
