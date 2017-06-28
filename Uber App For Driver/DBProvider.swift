//
//  DBProvider.swift
//  Uber App For Driver
//
//  Created by jimmy.gao on 6/27/17.
//  Copyright © 2017 eservicegroup. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    
    private static let _instance = DBProvider();
    static var Instance:DBProvider {
        return self._instance;
    }
    
    var dbRef:DatabaseReference {
        return Database.database().reference();
    }
    
    var driversRef:DatabaseReference{
        return dbRef.child(Constants.DRIVERS);
    }
    
    var requestRef:DatabaseReference{
        return dbRef.child(Constants.UBER_REQUEST);
    }
    
    var requestAcceptedRef:DatabaseReference{
        return dbRef.child(Constants.UBER_ACCEPTED);
    }
    
    
    
    func saveUser(withID:String, email:String, password:String) {
        let data:Dictionary<String, Any> = [Constants.EMAIL:email, Constants.PASSWORD:password, Constants.isRider: true];
        driversRef.child(withID).child(Constants.DATA).setValue(data);
    }
}
