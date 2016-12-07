//
//  BicycleMapViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 5..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit
import CoreLocation

class BicycleMapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet var menuItem : UIBarButtonItem!
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var mapViewFrame : UIView!

   
    var DKMapView : MTMapView?
    var currentLocation : CLLocation?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locman : CLLocationManager?
    var group = DispatchGroup()
    let searchKeyword = SearchKeyword()
    
    var searchActive : Bool = false
    
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
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        
        self.DKMapView = self.appDelegate.DKMapView
        self.DKMapView?.daumMapApiKey = DMApiKey
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        view.endEditing(true)
        let currentViewLocation = mapView?.camera.target
        
        self.searchKeyword.setKeyword(keyword: searchBar.text!,
                                      latitude: (currentViewLocation?.latitude)!,
                                      longitude: (currentViewLocation?.longitude)!,
                                      radius: 20000)
        let result = self.searchKeyword.search()
        
        if let _result = result {
            for element in _result {
            }
        } else {
            let errorAlertController = UIAlertController(title: "Error",
                                                         message: "Nothing is returned from server",
                                                         preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            errorAlertController.addAction(cancelAction)
            errorAlertController.show()
        }
    }
    
    
    func retrieveGMSCameraPosition() {
        DispatchQueue.global(qos: .userInteractive).async {
            while(true) {
                self.group.enter()
                if self.currentLocation != nil {
                    
                    DispatchQueue.main.async {
                       
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
