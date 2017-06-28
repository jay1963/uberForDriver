//
//  DriverVC.swift
//  Uber App For Driver
//
//  Created by jimmy.gao on 6/27/17.
//  Copyright © 2017 eservicegroup. All rights reserved.
//

import UIKit
import MapKit

class DriverVC: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate, UberController {
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var acceptedUberBtn: UIButton!
    
    
    private var locationManager = CLLocationManager();
    private var userLocation:CLLocationCoordinate2D?;
    private var riderLocation:CLLocationCoordinate2D?;
    
    private var timer = Timer();
    
    private var acceptedUber = false;
    private var driverCanceledUber = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.delegate = self;
        UberHandler.Instance.observeMessageForDrvier();

        // Do any additional setup after loading the view.
    }
    
    private func initializeLocationManager(){
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude);
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            myMap.setRegion(region, animated: true);
            myMap.removeAnnotations(myMap.annotations);
            if riderLocation != nil {
                if acceptedUber {
                    let riderAnnotation = MKPointAnnotation();
                    riderAnnotation.coordinate = riderLocation!;
                    riderAnnotation.title = "Riders Location";
                    myMap.addAnnotation(riderAnnotation);
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Drivers Location";
            myMap.addAnnotation(annotation);
        }
        
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        if AuthProvider.Instance.logOut() {
            if acceptedUber {
                acceptedUberBtn.isHidden = true;
                UberHandler.Instance.cancelUberForDriver();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
        }else{
            uberRequest(title: "Could Not Logout", message: "We could not logout at the moment, please try again later", requestAlive: false);
        }
    }
    
    func accteptedUber(lat: Double, long: Double) {
        if !acceptedUber {
            uberRequest(title: "Uber Request", message: "You have a request for an uber at this location Lat:\(lat), Long:\(long)", requestAlive: true);
        }
    }
    
    func riderCanceledUber() {
        if !driverCanceledUber {
            //cancel the uber from driver perspective
            self.acceptedUber = false;
            self.acceptedUberBtn.isHidden = true;
            uberRequest(title: "Uber Canceled", message: "The Rider Has Canceled The Uber Request", requestAlive: false);
        }
    }
    
    func uberCanceled() {
        acceptedUber = false;
        acceptedUberBtn.isHidden = true;
        //invalidate timer
        timer.invalidate();
    }
    
    func updateRidersLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    func updateDriversLocation(){
        UberHandler.Instance.updateDriversLocation(lat: Double((userLocation?.latitude)!), long: Double((userLocation?.longitude)!));
    }
    
    @IBAction func cancelUber(_ sender: AnyObject) {
        if acceptedUber {
            driverCanceledUber = true;
            acceptedUberBtn.isHidden = true;
            UberHandler.Instance.cancelUberForDriver();
            timer.invalidate();
        }
       
    }
    
   
    
    private func uberRequest(title:String, message:String, requestAlive:Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default) { (alertAction:UIAlertAction) in
                self.acceptedUber = true;
                self.acceptedUberBtn.isHidden = false;
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(DriverVC.updateDriversLocation), userInfo: nil, repeats: true);
                //inform that we accepted the Uber request
                UberHandler.Instance.uberAccepted(lat: Double((self.userLocation?.latitude)!), long: Double((self.userLocation?.longitude)!));
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil);
            alert.addAction(accept);
            alert.addAction(cancel);
        }else{
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
            alert.addAction(ok);
        }
        present(alert, animated: true, completion: nil);
    }
    
}
