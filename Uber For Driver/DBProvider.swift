//
//  DBProvider.swift
//  Uber For Driver
//
//  Created by Haider Rasool on 3/31/17.
//  Copyright © 2017 Haider Rasool. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    
    private static let _instance : DBProvider = DBProvider();
    static var Instance : DBProvider {
        return _instance;
    }
    
    var databaseref : FIRDatabaseReference{
        return FIRDatabase.database().reference();
    }
    
    var driverRef : FIRDatabaseReference{
        return self.databaseref.child(Constants.DRIVERS);
    }
    var uberAcceptedRef : FIRDatabaseReference{
        return self.databaseref.child(Constants.UBER_ACCEPTED);
    }
    var uberRequestedRef : FIRDatabaseReference{
        return self.databaseref.child(Constants.UBER_REQUEST);
    }
    
    //UBER REQUEST
    
    //UBER ACCEPTED
    
    public func SaveUser ( UID : String, Email : String, Password : String)
    {
        let data : Dictionary <String, Any> = [Constants.EMAIL : Email, Constants.PASSWORD : Password, Constants.ISRIDER : false]
        self.driverRef.child(UID).child(Constants.DATA).setValue(data);
        
    }
}
