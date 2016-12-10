//
//  AppDelegate.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 11. 30..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locman : CLLocationManager?
    let DKMapView = MTMapView()
    var SKMapView : TMapView?
    var manageHolder : ManagerHolder?
    let executionGroup = DispatchGroup()    // Semaphore when figuring out whether it's good to go
    
    var startLocation : CLLocation?
    var lastLocation : CLLocation?
    var prevlastLocation : CLLocation?
    
    var lastDistance : Double?
    var velocity : Double?
    var traveledDistance = 0.0
    var accuracy : Double?
    
    var flag : Bool = false
    var flagAccumulate : Bool = false
    
    var REQ_ACC = 100.0


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Update the navigation bar's font style and size
        if let barFont = UIFont(name: "Avenir-Light", size: 24.0) {
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName:barFont]
        }
        UIApplication.shared.statusBarStyle = .lightContent
        // Allocate CLLocationManager and set its attributes
        self.locman = CLLocationManager()
        self.locman?.desiredAccuracy = kCLLocationAccuracyBest
        self.locman?.activityType = .fitness
        self.locman?.startUpdatingLocation()
        self.manageHolder = ManagerHolder(locationManager: self.locman!)
        
        self.locman?.delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Execute when the user gives us right to use GPS
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.global(qos: .background).async {
                self.manageHolder?.doThisWhenAuthorized?()
            }
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if startLocation == nil {
            // Initialize the first and last location
            startLocation = locations.first
            lastLocation = locations.last
        } else {
            // Calculate velocity of the current location
            self.velocity = abs((lastLocation?.speed)!) * 3600.0 / 1000.0
            // Update two consecutive last locations
            self.prevlastLocation = self.lastLocation
            self.lastLocation = locations.last
            // Calculate the distance between those two locations
            self.lastDistance = prevlastLocation?.distance(from: lastLocation!)
            if self.flagAccumulate {
                self.traveledDistance += self.lastDistance!
            }
        }
        // Update flag whether it's good to go
        self.accuracy = self.lastLocation?.horizontalAccuracy
        print("Loop")
        if self.flag {
            if self.accuracy! >= 0 && self.accuracy! < REQ_ACC {
                print("Done")
                self.flag = false
            }
        }
        if self.SKMapView != nil {
            print("Marking coordinate")
            let currentMarker = TMapMarkerItem2(tMapPoint: TMapPoint(coordinate: (lastLocation?.coordinate)!))
            currentMarker?.setIcon(UIImage(named: "Bicycle"))
            self.SKMapView?.removeTMapMarkerItemID("current")
            self.SKMapView?.addTMapMarkerItemID("current", markerItem2: currentMarker)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorAlertController = UIAlertController(title: "Error",
                                                     message: error.localizedDescription,
                                                     preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlertController.addAction(cancelAction)
        errorAlertController.show()
    }
}

