//
//  UberHandler.swift
//  Uber For Driver
//
//  Created by Haider Rasool on 4/1/17.
//  Copyright © 2017 Haider Rasool. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController : class {
    func acceptUber(name:String, longitude:Double, latitude:Double);
}

class UberHandler{
    private static let _instance = UberHandler();
    
    public static var Instance : UberHandler{
        return _instance;
    }
    
    weak var delegate : UberController?;
    
    //public var uberid : String?;
    public var driver : String?;
    public var rider : String?;
    public var UberRequestKey : String?;
    
    public func StartListeningtoUberRequests()
    {
        //New Requests
        DBProvider.Instance.uberRequestedRef.observe(.childAdded, with: { (snapshot) in
            if var data = snapshot.value as? Dictionary<String,Any>{
                
                if let longitude = data[Constants.LONGITUDE] as? Double{
                    
                    if let latitude = data[Constants.LATITUDE] as? Double{
                        
                        if let name = data[Constants.NAME] as? String{
                            self.UberRequestKey = snapshot.key;
                            self.delegate?.acceptUber(name: name, longitude: longitude, latitude: latitude);
                        }
                    }
                }
            }
        });
        
        //Canceled Requests
    }
    public func AcceptUber(longitude : Double, latitude : Double)
    {
        if self.UberRequestKey != nil {
            let data : Dictionary<String,Any> = [ Constants.NAME : self.driver!, Constants.LONGITUDE : longitude, Constants.LATITUDE : latitude ];
            DBProvider.Instance.uberAcceptedRef.child(self.UberRequestKey!).setValue(data);
        }
    }
    public func UpdateDriverLocation(lon : Double, lat : Double)
    {
        if self.UberRequestKey != nil {
            let data : Dictionary<String,Any> = [ Constants.LONGITUDE : lon, Constants.LATITUDE : lat ];
            DBProvider.Instance.uberAcceptedRef.child(self.UberRequestKey!).updateChildValues(data);
        }
    }
    
}
























