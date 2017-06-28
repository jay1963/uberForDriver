//
//  UberHandler.swift
//  Uber App For Driver
//
//  Created by jimmy.gao on 6/27/17.
//  Copyright © 2017 eservicegroup. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController:class {
    func accteptedUber(lat:Double, long:Double);
    func riderCanceledUber();
    func uberCanceled();
    func updateRidersLocation(lat:Double, long:Double);
}

class UberHandler {
    
    private static let _instance = UberHandler();
    
    weak var delegate:UberController?;
    
    var rider = "";
    var driver = "";
    var driver_id = "";
    
    static var Instance:UberHandler {
        return _instance;
    }
    
    func observeMessageForDrvier(){
        //Rider Request Uber
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        // inform the driver VC
                        self.delegate?.accteptedUber(lat: latitude, long: longitude);
                    }
                }
                if let name = data[Constants.NAME] as? String{
                    self.rider = name;
                }
            }
        }
        
        //Rider Cancel Uber
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.rider = "";
                        self.delegate?.riderCanceledUber();
                    }
                }
            }
        }
        
        //Driver Accepted Uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver_id = snapshot.key;
                    }
                }
            }
        }
        //Driver Canceled Uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver_id = snapshot.key;
                        self.delegate?.uberCanceled();
                    }
                }
            }
        }
        
        //Rider Update Location
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double{
                    if let long = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.updateRidersLocation(lat: lat, long: long);
                    }
                }
            }
        }
        
    }
    
    func uberAccepted(lat:Double, long:Double){
        let data:Dictionary<String,Any> = [Constants.NAME:driver, Constants.LATITUDE:lat, Constants.LONGITUDE:long];
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data);
        
    }
    
    func cancelUberForDriver() {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue();
        
    }
    
    func updateDriversLocation(lat:Double, long:Double){
        DBProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LATITUDE:lat, Constants.LONGITUDE:long]);
    }
}
