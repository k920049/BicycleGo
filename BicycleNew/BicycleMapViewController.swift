//
//  BicycleMapViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 5..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class BicycleMapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var menuItem : UIBarButtonItem!

    var cameraPosition : GMSCameraPosition?
    var mapView : GMSMapView?
    var DKMapView : MTMapView?
    var marker : GMSMarker?
    var currentLocation : CLLocation?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var locman : CLLocationManager?
    
    var group = DispatchGroup()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.locman = self.appDelegate.locman
        self.locman?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.locman?.delegate = self
        self.retrieveGMSCameraPosition()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSideBarMenu(leftMenuButton: menuItem)

        // Do any additional setup after loading the view.
        if !CLLocationManager.locationServicesEnabled() {
            self.locman?.desiredAccuracy = kCLLocationAccuracyBest
            self.locman?.activityType = .fitness
            self.locman?.startUpdatingLocation()
        }
        
        
        GMSServices.provideAPIKey(GMApiKey)
        self.retrieveGMSCameraPosition()
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0,
                                                        width: self.view.frame.size.width, height: self.view.frame.size.height),
                                      camera: GMSCameraPosition.camera(withLatitude: 37.5663, longitude: 126.9779, zoom: 12) )
        
        self.view.addSubview(self.mapView!)
        
        self.DKMapView = MTMapView(frame: CGRect.zero)
        self.DKMapView?.daumMapApiKey = DMApiKey
        
        
        
    }
    
    func retrieveGMSCameraPosition() {
        DispatchQueue.global(qos: .userInteractive).async {
            while(true) {
                self.group.enter()
                if self.currentLocation != nil {
                    print("loop")
                    self.cameraPosition = GMSCameraPosition.camera(withLatitude: (self.currentLocation?.coordinate.latitude)!, longitude: (self.currentLocation?.coordinate.longitude)!, zoom: 12)
                    self.cameraPosition = GMSCameraPosition.camera(withTarget: (self.currentLocation?.coordinate)!, zoom: 12)
                    DispatchQueue.main.async {
                        self.mapView?.camera = self.cameraPosition!
                        print("done")
                    }
                    break
                }
                self.group.leave()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("entered")
        group.enter()
        if let locationCandidate = locations.last {
            let acc = locationCandidate.horizontalAccuracy
            if acc <= 65.0 {
                self.currentLocation = locations.last
                print(String(format: "Latitude : %.2f, Longitude : %.2f", (currentLocation?.coordinate.latitude)!, (currentLocation?.coordinate.longitude)!))
            }
        } else {
            let errorAlertController = UIAlertController(title: "Error",
                                                         message: "Cannot update current location",
                                                         preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            errorAlertController.addAction(cancelAction)
            errorAlertController.show()
        }
        group.leave()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorAlertController = UIAlertController(title: "Error",
                                                     message: error.localizedDescription,
                                                     preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlertController.addAction(cancelAction)
        errorAlertController.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
