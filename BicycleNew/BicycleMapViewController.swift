//
//  BicycleMapViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 5..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Darwin

class BicycleMapViewController: UIViewController,
    TMapViewDelegate,
    TMapGpsManagerDelegate,
    UISearchBarDelegate,
    TMapPathDelegate {
    @IBOutlet var menuItem : UIBarButtonItem!
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var mapViewFrame : UIView!
    @IBOutlet var compass : UIBarButtonItem!
    @IBOutlet var sight : UIButton!
    
    var DKMapView : MTMapView?
    var SKMapView : TMapView?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let searchKeyword = SearchKeyword()
    
    var searchActive : Bool = false
    var sightMode : Int = 0
    var markerArray : [TMapMarkerItem2]? = nil
    var image = UIImage(named: "marker")
    
    @IBAction func didSelectCompass(sender : UIBarButtonItem) {
        if sender == compass {
            self.appDelegate.locman?.startUpdatingLocation()
            
            self.SKMapView?.setCenter(TMapPoint(coordinate: (self.appDelegate.lastLocation?.coordinate)!))
            
            let currentMarker = TMapMarkerItem2(tMapPoint: TMapPoint(coordinate: (self.appDelegate.lastLocation?.coordinate)!))
            currentMarker?.setIcon(UIImage(named: "Bicycle"))
            self.SKMapView?.removeTMapMarkerItemID("current")
            self.SKMapView?.addTMapMarkerItemID("current", markerItem2: currentMarker)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .userInteractive).async {
            while(true) {
                if let lastLocation = self.appDelegate.lastLocation {
                    DispatchQueue.main.async {
                        self.SKMapView?.setCenter(lastLocation.coordinate, animated: true)
                    }
                    break
                }
            }
        }
    }
    
    func drawRecommendedRoad(startLocation : CLLocation?,
                             endLocation : CLLocation?,
                             bypassArray : [(Double, Double)]?) {
        let path = TMapPathData()
        var bypassTMapPointArray = [TMapPoint]()
        let startPoint : TMapPoint? = TMapPoint(coordinate: (startLocation?.coordinate)!)
        let endPoint : TMapPoint? = TMapPoint(coordinate: (endLocation?.coordinate)!)
        var polyline : TMapPolyLine?
        
        let top = (startLocation?.coordinate.latitude)! > (endLocation?.coordinate.latitude)! ? startLocation?.coordinate.latitude : endLocation?.coordinate.latitude
        let left = (startLocation?.coordinate.longitude)! < (endLocation?.coordinate.longitude)! ? startLocation?.coordinate.longitude : endLocation?.coordinate.longitude
        let bottom = (startLocation?.coordinate.latitude)! < (endLocation?.coordinate.latitude)! ? startLocation?.coordinate.latitude : endLocation?.coordinate.latitude
        let right = (startLocation?.coordinate.longitude)! > (endLocation?.coordinate.longitude)! ? startLocation?.coordinate.longitude : endLocation?.coordinate.longitude
        let centerLatitude = ((startLocation?.coordinate.latitude)! + (endLocation?.coordinate.latitude)!) / 2.0
        let centerLongitude = ((startLocation?.coordinate.longitude)! + (endLocation?.coordinate.longitude)!) / 2.0
        let topLeft = TMapPoint(coordinate: CLLocationCoordinate2D(latitude: top!, longitude: left!))
        let bottomRight = TMapPoint(coordinate: CLLocationCoordinate2D(latitude: bottom!, longitude: right!))
        let center = TMapPoint(coordinate: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude))
        
    
        if let _bypassArray = bypassArray {
            self.SKMapView?.removeAllTMapMarkerItems()
            self.SKMapView?.removeAllTMapPolyLines()
            
            self.addMarker(title: "start", subTitle: "Description",
                           position: CLLocation(latitude: (startPoint?.getLatitude())!,
                                                longitude: (startPoint?.getLongitude())!))
            self.addMarker(title: "end", subTitle: "Description",
                           position: CLLocation(latitude: (endPoint?.getLatitude())!,
                                                longitude: (endPoint?.getLongitude())!))
            
            self.markerArray?.removeAll()
            self.image = UIImage(named: "bypass")
            for element in _bypassArray {
                let item = TMapPoint(lon: element.1, lat: element.0)
                self.addMarker(title: String(arc4random_uniform(1024)),
                               subTitle: "Description",
                               position: CLLocation(latitude: element.0, longitude: element.1))
                bypassTMapPointArray.append(item!)
            }
            self.image = UIImage(named: "marker")
            polyline = path.find(with: BICYCLE_PATH,
                                 start: startPoint!,
                                 end: endPoint!,
                                 passPoints: bypassTMapPointArray,
                                 searchOption: 0)
            if polyline == nil {
                path.find(with: CAR_PATH,
                          start: startPoint!,
                          end: endPoint!,
                          passPoints: bypassTMapPointArray,
                          searchOption: 0)
                if polyline == nil {
                    var polyLineArray = [TMapPolyLine]()
                    let startPolyline = path.find(with: BICYCLE_PATH,
                                                 start: startPoint,
                                                 end: bypassTMapPointArray[0])
                    if startPolyline != nil {
                        polyLineArray.append(startPolyline!)
                    }
                    self.SKMapView?.showAllPolyLine(polyLineArray)
                    for ix in 1...bypassTMapPointArray.count - 1 {
                        let eachPolyline = path.find(with: BICYCLE_PATH,
                                                     start: bypassTMapPointArray[ix - 1],
                                                     end: bypassTMapPointArray[ix])
                        if eachPolyline != nil {
                            polyLineArray.append(eachPolyline!)
                        }
                        // self.SKMapView?.showAllPolyLine(polyLineArray)
                    }
                    /*let endPolyline = path.find(with: BICYCLE_PATH,
                                                 start: bypassTMapPointArray[bypassTMapPointArray.count - 1],
                                                 end: endPoint)
                    if endPolyline != nil {
                        polyLineArray.append(endPolyline!)
                    }*/
                    // self.SKMapView?.showAllPolyLine(polyLineArray)
                } else {
                    self.SKMapView?.addTMapPath(polyline)
                }
            } else {
                self.SKMapView?.addTMapPath(polyline)
            }
            
        } else {
            polyline = path.find(with: BICYCLE_PATH,
                                 start: startPoint!,
                                 end: endPoint!)
            self.SKMapView?.addTMapPath(polyline)
        }
        self.SKMapView?.zoom(toTMapPointLeftTop: topLeft, rightBottom: bottomRight)
        self.SKMapView?.setCenter(center)
        self.SKMapView?.zoomOut()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSideBarMenu(leftMenuButton: menuItem)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 245/255, blue: 255/255, alpha: 1.0)
        
        self.appDelegate.SKMapView = TMapView(frame: CGRect(x: 0, y: 0,
                                                           width: self.view.frame.size.width,
                                                           height: self.view.frame.size.height))
        self.SKMapView = self.appDelegate.SKMapView
        self.SKMapView?.setSKPMapApiKey(SKApiKey)
        self.SKMapView?.delegate = self
        self.SKMapView?.gpsManagersDelegate = self
        self.SKMapView?.clipsToBounds = true
        self.SKMapView?.setBicycleInfo(true)
        self.SKMapView?.setBicycleFacilityInfo(true)
        self.SKMapView?.zoomLevel = 12
        self.mapViewFrame.addSubview(self.SKMapView!)
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        
        self.DKMapView = self.appDelegate.DKMapView
        self.DKMapView?.daumMapApiKey = DMApiKey
        
        let rootTabBarController = self.tabBarController as! BicycleTabBarController
        if let _currentRoad = rootTabBarController.currentRoad {
            
            let startLocation = CLLocation(latitude: _currentRoad.startLatitude!,
                                           longitude: _currentRoad.startLongitude!)
            let endLocation = CLLocation(latitude: _currentRoad.endLatitude!,
                                         longitude: _currentRoad.endLongitude!)
            
            let bypassArray = _currentRoad.authCenter
            drawRecommendedRoad(startLocation: startLocation,
                                endLocation: endLocation,
                                bypassArray: bypassArray)
            rootTabBarController.currentRoad = nil
        }
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
        let currentViewLocation = SKMapView?.centerCoordinate()
        
        self.searchKeyword.setKeyword(keyword: searchBar.text!,
                                      latitude: (currentViewLocation?.latitude)!,
                                      longitude: (currentViewLocation?.longitude)!,
                                      radius: 20000)
        let result = self.searchKeyword.search()
        if let _result = result {
            self.SKMapView?.removeAllTMapMarkerItems()
            
            for element in _result {
                self.addMarker(title: element.title, subTitle: "Description", position: CLLocation(latitude: element.latitude, longitude: element.longitude))
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
    
    func locationChanged(_ newTmp: TMapPoint!) {
        
    }
    
    func headingChanged(_ heading: Double) {
        
    }
    
    
    func onClick(_ TMP: TMapPoint!) {
        if self.markerArray != nil && self.markerArray!.count > 0 {
            print("Calculating path")
            let location = CLLocation(latitude: TMP.coordinate.latitude, longitude: TMP.coordinate.longitude)
            print(location)
            var nearest : CLLocation? = nil
            var distance = DBL_MAX
            for element in self.markerArray! {
                let _currentLocation = CLLocation(latitude: element.coordinate.latitude, longitude: element.coordinate.longitude)
                let currentDistance = abs(location.distance(from: _currentLocation))
                if distance > currentDistance {
                    print(String(format: "%f", currentDistance))
                    distance = currentDistance
                    nearest = _currentLocation
                }
            }
            
            let path = TMapPathData()
            let startPoint = TMapPoint(coordinate: (self.appDelegate.lastLocation?.coordinate)!)
            let endPoint = TMapPoint(coordinate: (nearest?.coordinate)!)
            
            let top = (startPoint?.getLatitude())! > (endPoint?.getLatitude())! ? startPoint?.coordinate.latitude : endPoint?.coordinate.latitude
            let left = (startPoint?.getLongitude())! < (endPoint?.getLongitude())! ? startPoint?.coordinate.longitude : endPoint?.coordinate.longitude
            let bottom = (startPoint?.getLatitude())! < (endPoint?.getLatitude())! ? startPoint?.coordinate.latitude : endPoint?.coordinate.latitude
            let right = (startPoint?.getLongitude())! > (endPoint?.getLongitude())! ? startPoint?.coordinate.longitude : endPoint?.coordinate.longitude
            let centerLatitude = ((startPoint?.getLatitude())! + (endPoint?.getLatitude())!) / 2.0
            let centerLongitude = ((startPoint?.getLongitude())! + (endPoint?.getLongitude())!) / 2.0
            
            let topLeft = TMapPoint(coordinate: CLLocationCoordinate2D(latitude: top!, longitude: left!))
            let bottomRight = TMapPoint(coordinate: CLLocationCoordinate2D(latitude: bottom!, longitude: right!))
            let center = TMapPoint(coordinate: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude))
            
            let polyline = path.find(with: BICYCLE_PATH, start: startPoint, end: endPoint)
            var polyArray = [TMapPolyLine]()
            polyArray.append(polyline!)
            
            self.SKMapView?.removeAllTMapPolyLines()
            self.SKMapView?.addTMapPath(polyline)
            self.SKMapView?.zoom(toTMapPointLeftTop: topLeft, rightBottom: bottomRight)
            self.SKMapView?.setCenter(center)
            self.SKMapView?.zoomOut()
            // self.SKMapView?.showAllPolyLine(polyArray)
        }
    }
    
    func addMarker(title : String?, subTitle : String?, position : CLLocation?) {
    
        if self.markerArray == nil {
            self.markerArray = [TMapMarkerItem2]()
        }
        
        if let position = position {
            let mapPoint = TMapPoint(coordinate: position.coordinate)
            let mapMarker = TMapMarkerItem2()
            mapMarker.setTMapPoint(mapPoint)
            mapMarker.setIcon(image)
            
            self.markerArray?.append(mapMarker)
            self.SKMapView?.addTMapMarkerItemID(title?.sha1(), markerItem2: mapMarker)
        }
        
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
