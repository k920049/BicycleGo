//
//  BicycleManagerHolder.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 2..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation
import CoreLocation

class ManagerHolder {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locman : CLLocationManager?
    var doThisWhenAuthorized : (() -> ())?
    
    init() {
        self.locman = appDelegate.locman
    }
    
    func checkForLocationAccess(always : Bool = false, andThen f:(() -> ())? = nil) {
        guard CLLocationManager.locationServicesEnabled() else {
            self.locman?.startUpdatingLocation()
            return
        }
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.doThisWhenAuthorized = f
            f?()
        case .notDetermined:
            self.doThisWhenAuthorized = f
        case .restricted:
            break
        case .denied:
            break
        }
    }
}
