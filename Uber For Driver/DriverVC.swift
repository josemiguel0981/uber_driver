//
//  DriverVC.swift
//  Uber For Driver
//
//  Created by Haider Rasool on 3/28/17.
//  Copyright © 2017 Haider Rasool. All rights reserved.
//

import UIKit
import MapKit

class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController{

    @IBOutlet weak var map_driver: MKMapView!
    @IBOutlet weak var btn_cancel: UIButton!
    
    var locationManger = CLLocationManager();
    var userlocation : CLLocationCoordinate2D?;
    var riderlocation: CLLocationCoordinate2D?;
    var timer : Timer = Timer();
    override func viewDidLoad() {
        super.viewDidLoad()

        UberHandler.Instance.delegate = self;
        UberHandler.Instance.StartListeningtoUberRequests();
        
        locationManger.delegate = self;
        locationManger.desiredAccuracy = kCLLocationAccuracyBest;
        locationManger.requestWhenInUseAuthorization();
        locationManger.startUpdatingLocation();
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationcoordinates = locationManger.location?.coordinate{
            
            self.userlocation = CLLocationCoordinate2D(latitude: locationcoordinates.latitude, longitude: locationcoordinates.longitude);
            let region = MKCoordinateRegion(center: self.userlocation!, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005));
            self.map_driver.setRegion(region, animated: true);
            
            self.map_driver.removeAnnotations(self.map_driver.annotations);
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = self.userlocation!;
            annotation.title = "Driver";
            self.map_driver.addAnnotation(annotation);
            
            if self.btn_cancel.isEnabled {  //Customer Inbound
                if self.riderlocation != nil{
                    let riderannotation = MKPointAnnotation();
                    riderannotation.coordinate = self.riderlocation!;
                    annotation.title = "Rider";
                    self.map_driver.addAnnotation(riderannotation);
                }
            }
        }
    }
    @IBAction func action_cancelUber(_ sender: Any) {
        self.btn_cancel.isEnabled = false;
    }

    @IBAction func action_logout(_ sender: Any) {
        if AuthProvider.Instance.logout(){
            if self.self.btn_cancel.isEnabled{
                timer.invalidate();
                dismiss(animated: true, completion: nil);
            }
        }else{
            self.showAlert(msg: "Error Logging Out! Try again.", title: "LogoutError", isRequest: false);
        }
    }
    func showAlert( msg:String, title: String, isRequest : Bool)
    {
        let alertctrl = UIAlertController(title: title, message: msg, preferredStyle: .alert);
        
        if isRequest == true{
            let acceptbtn = UIAlertAction(title: "Accept", style: .default, handler: { (uiActionAlert) in
                self.uberAccepted();
            });
            let cancelbtn = UIAlertAction(title: "Cancel", style: .default, handler: { (uiActionAlert) in
                self.uberCanceled();
            });
            alertctrl.addAction(acceptbtn);
            alertctrl.addAction(cancelbtn);
        }else{
            let okbtn = UIAlertAction(title: "Ok", style: .default, handler: nil);
            alertctrl.addAction(okbtn);
        }
        present(alertctrl, animated: true, completion: nil);
    }
    
    func uberAccepted()
    {
        self.btn_cancel.isEnabled = true;   //Customer Inbound
        if userlocation != nil{
            UberHandler.Instance.AcceptUber(longitude: (userlocation?.longitude)!, latitude: (userlocation?.latitude)!);    //Informing the user
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(timertick), userInfo: nil, repeats: true);
        }
    }
    func uberCanceled()
    {
        //Proceed
    }
    
    func acceptUber(name: String, longitude: Double, latitude: Double) {
        
        self.riderlocation = CLLocationCoordinate2D(latitude: latitude,longitude: longitude);
        
        showAlert(msg: "Our customer \"\(name)\" has requested an Uber at LON: \(longitude) and LAT: \(latitude).", title: "New Uber Request", isRequest: true);
    }
    func timertick()
    {
        if userlocation != nil{
            UberHandler.Instance.UpdateDriverLocation(lon: (userlocation?.longitude)!, lat: (userlocation?.latitude)!);
        }
    }
}
