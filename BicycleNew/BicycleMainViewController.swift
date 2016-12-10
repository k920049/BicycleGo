//
//  BicycleMainViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 11. 30..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit
import GaugeKit
import CoreLocation
import Darwin

class BicycleMainViewController: UIViewController {
    @IBOutlet var menuItem : UIBarButtonItem!
    @IBOutlet var buttonPlay : UIButton!
    @IBOutlet var speedometerView : UIView!
    @IBOutlet var speedometerLabel : UILabel!
    @IBOutlet var gaugeMiddle : Gauge!
    @IBOutlet var startButton : UIButton!
    @IBOutlet var endButton : UIButton!
    
    @IBOutlet var weatherImage : UIImageView!
    @IBOutlet var directionImage : UIImageView!
    
    @IBOutlet var temparature : UILabel!
    @IBOutlet var windspeed : UILabel!
    @IBOutlet var humidity : UILabel!
    @IBOutlet var chanceOfRain : UILabel!
    @IBOutlet var timeAccumulated : UILabel!
    @IBOutlet var distanceAccumulated : UILabel!
    @IBOutlet var calori : UILabel!
    
    var city : String = ""
    var cityCode : String = ""
    var province : String = ""
    var provinceCode : String = ""
    var town : String = ""
    var townCode : String = ""

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var DMapView : MTMapView?
    var manageHolder : ManagerHolder?
    var locman : CLLocationManager? {
        return self.manageHolder?.locman
    }
    var timer = Timer()
   
    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var prevlastLocation: CLLocation!
    var loc: CLLocation!
    var counter = 0
    var traveledDistance:Double = 0
    var shouldEndExecute : Bool = false
    var isInitial : Bool = true
    var isStarted : Bool = false
    
    var weatherImages = ["Sunny", "PartlyCloudy", "Rain", "RainANDSnow"]
    var directionImages = ["North", "NorthEast", "East", "SouthEast", "South", "SouthWest", "West", "NorthWest"]
    
    @IBAction func buttonClicked(sender : UIButton) {
        // Executed when the play button is clicked
        if(sender == buttonPlay) {
            buttonPlay.isHidden = true
            speedometerView.isHidden = false
            startButton.isHidden = false
            endButton.isHidden = false
        } else if(sender == endButton) {
            self.isStarted = false
            self.appDelegate.flagAccumulate = false
            self.shouldEndExecute = true
            
            buttonPlay.isHidden = false
            speedometerView.isHidden = true
            startButton.isHidden = true
            endButton.isHidden = true
            timer.invalidate()
            
            secondsToHoursMinutesSeconds(counter, result: { (h, m, s) in
                self.timeAccumulated.text = "\(self.timeText(h)):\(self.timeText(m)):\(self.timeText(s))"
            })
            // Stores accumulated counter to UserDefaults
            UserDefaults.standard.set(self.counter, forKey: "Accumulated counter")
        } else if(sender == startButton) {
            if isStarted {
                
            } else {
                isStarted = true
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BicycleMainViewController.updateCounter), userInfo: nil, repeats: true)
                
                self.appDelegate.flagAccumulate = true
                self.shouldEndExecute = false
                DispatchQueue.global(qos: .userInteractive).async {
                    while(true) {
                        if self.shouldEndExecute {
                            print("Break")
                            break
                        }
                        self.appDelegate.locman?.startUpdatingLocation()
                        self.appDelegate.executionGroup.wait()
                        self.appDelegate.executionGroup.enter()
                        self.appDelegate.flag = true
                        while(true) {
                            if !self.appDelegate.flag {
                                DispatchQueue.main.async {
                                    self.gaugeMiddle.rate = CGFloat(self.appDelegate.velocity! / 6.0)
                                    self.speedometerLabel.text = String(format: "%.1f km/h", self.appDelegate.velocity!)
                                    self.distanceAccumulated.text = String(format: "%.1f m", self.appDelegate.traveledDistance)
                                }
                                break
                            }
                            sleep(1)
                        }
                        self.appDelegate.executionGroup.leave()
                    }
                }
            }
            
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        var _error : Bool = false
        DispatchQueue.global(qos: .userInteractive).async {
            // Inquire the location manager whether it's good to go
            if self.isInitial {
                self.isInitial = false
                // Wait till previous thread completes its execution
                self.appDelegate.executionGroup.wait()
                self.appDelegate.executionGroup.enter()
                self.appDelegate.flag = true
                while(true) {
                    if !self.appDelegate.flag {
                        DispatchQueue.main.async {
                            self.DMapView?.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: (self.appDelegate.lastLocation?.coordinate.latitude)!, longitude: (self.appDelegate.lastLocation?.coordinate.longitude)!)),
                                                        animated: false)
                        }
                        break
                    }
                    sleep(1)
                }
                self.appDelegate.executionGroup.leave()
            }
            
            // And then register a closure for further execution
            self.appDelegate.manageHolder?.checkForLocationAccess(always: false, andThen: { () -> Void in
                if let DMapView = self.DMapView {
                    // Get a human readable address from CLLocation using Daum Map API
                    MTMapReverseGeoCoder.executeFindingAddress(for: DMapView.mapCenterPoint,
                                                               openAPIKey: DMApiKey,
                                                               completionHandler: {(success , addressForMapPoint , error) -> Void in
                                                                if(success) {
                                                                    let eachAddress : [String] = (addressForMapPoint?.components(separatedBy: " "))!
                                                                    self.city = eachAddress[0]
                                                                    self.province = eachAddress[1]
                                                                    self.town = eachAddress[2]
                                                                    
                                                                    if(!_error) {
                                                                        let searchAddress = SearchAddress()
                                                                        searchAddress.setModeCity()
                                                                        if let result = searchAddress.search() {
                                                                            let parsed = self.parseJson(data: result)
                                                                            for element in parsed {
                                                                                if element.value == self.city {
                                                                                    self.cityCode = element.code
                                                                                    break
                                                                                }
                                                                            }
                                                                        } else {
                                                                            _error = true
                                                                            let errorAlertController = UIAlertController(title: "Error",
                                                                                                                         message: "City code not found",
                                                                                                                         preferredStyle: .actionSheet)
                                                                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                                            errorAlertController.addAction(cancelAction)
                                                                            errorAlertController.show()
                                                                        }
                                                                        
                                                                        if(!_error) {
                                                                            searchAddress.setModeProvince(addressCode: self.cityCode)
                                                                            if let result = searchAddress.search() {
                                                                                let parsed = self.parseJson(data: result)
                                                                                for element in parsed {
                                                                                    if element.value == self.province {
                                                                                        self.provinceCode = element.code
                                                                                        break
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                _error = true
                                                                                let errorAlertController = UIAlertController(title: "Error",
                                                                                                                             message: "Province code not found",
                                                                                                                             preferredStyle: .actionSheet)
                                                                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                                                errorAlertController.addAction(cancelAction)
                                                                                errorAlertController.show()
                                                                            }
                                                                        }
                                                                        
                                                                        if(!_error) {
                                                                            searchAddress.setModeTown(addressCode: self.provinceCode)
                                                                            if let result = searchAddress.search() {
                                                                                let parsed = self.parseJson(data: result)
                                                                                for element in parsed {
                                                                                    if element.value == self.town {
                                                                                        self.townCode = element.code
                                                                                        break
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                _error = true
                                                                                let errorAlertController = UIAlertController(title: "Error",
                                                                                                                             message: "Province code not found",
                                                                                                                             preferredStyle: .actionSheet)
                                                                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                                                errorAlertController.addAction(cancelAction)
                                                                                errorAlertController.show()
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    if(!_error) {
                                                                        let searchKMA = SearchKMA()
                                                                        
                                                                        searchKMA.search(townCode: self.townCode, completionHandler: {(array : [ItemRSS]) -> Void in
                                                                            DispatchQueue.main.async(){
                                                                                self.updateStatus(rssArray: array)
                                                                                let errorAlertController = UIAlertController(title: "Found",
                                                                                                                             message: String(format : "Done", self.townCode),
                                                                                                                             preferredStyle: .actionSheet)
                                                                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                                                errorAlertController.addAction(cancelAction)
                                                                                errorAlertController.show()
                                                                            }
                                                                            
                                                                        })
                                                                    }
                                                                }
                                                                
                                                                if let error = error {
                                                                    _error = true
                                                                    DispatchQueue.main.async(){
                                                                        let errorAlertController = UIAlertController(title: "Error",
                                                                                                                     message: error.localizedDescription,
                                                                                                                     preferredStyle: .actionSheet)
                                                                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                                        errorAlertController.addAction(cancelAction)
                                                                        errorAlertController.show()
                                                                    }
                                                                }
                    })
                } else {
                    _error = true
                    let errorAlertController = UIAlertController(title: "Error",
                                                                 message: "MTMapView is not initialized",
                                                                 preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    errorAlertController.addAction(cancelAction)
                    errorAlertController.show()
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSideBarMenu(leftMenuButton: menuItem)
    
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 245/255, blue: 255/255, alpha: 1.0)
        self.DMapView = self.appDelegate.DKMapView
        self.DMapView?.daumMapApiKey = DMApiKey
        self.DMapView?.currentLocationTrackingMode = MTMapCurrentLocationTrackingMode.onWithoutHeading
        self.view.addSubview(self.DMapView!)
        
        speedometerView.layer.cornerRadius = 128.0
        gaugeMiddle.layer.cornerRadius = 96.0
        
        buttonPlay.isHidden = false
        speedometerView.isHidden = true
        startButton.isHidden = true
        endButton.isHidden = true
        
        if let _counter = UserDefaults.standard.integer(forKey: "Accumulated counter") as Int?{
            self.counter = _counter
        }
        
        secondsToHoursMinutesSeconds(counter, result: { (h, m, s) in
            self.timeAccumulated.text = "\(self.timeText(h)):\(self.timeText(m)):\(self.timeText(s))"
        })
        distanceAccumulated.text = String(format: "%f m", 0.0)
    }
    
    func updateCounter() {
        counter = counter + 1
        secondsToHoursMinutesSeconds(counter, result: { (h, m, s) in
            self.timeAccumulated.text = "\(self.timeText(h)):\(self.timeText(m)):\(self.timeText(s))"
        })
    }
    
    func secondsToHoursMinutesSeconds(_ seconds : Int, result: @escaping (Int, Int, Int)->()) {
        result(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func timeText(_ s: Int) -> String {
        return s < 10 ? "0\(s)" : "\(s)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateStatus(rssArray : [ItemRSS]) -> Void {
        let newest = rssArray[0]
        
        switch newest.pty {
        case 0:
            switch newest.sky {
            case 1:
                self.weatherImage.image = UIImage(named: self.weatherImages[0])!
            case 2,3,4:
                self.weatherImage.image = UIImage(named: self.weatherImages[1])!
            default:
                break
            }
        case 1:
            self.weatherImage.image = UIImage(named: self.weatherImages[2])!
        case 2, 3:
            self.weatherImage.image = UIImage(named: self.weatherImages[3])!
        default:
            break
        }
        self.weatherImage.reloadInputViews()
        
        switch newest.wdKor {
        case "북":
            self.directionImage.image = UIImage(named: self.directionImages[0])!
        case "북서":
            self.directionImage.image = UIImage(named: self.directionImages[1])!
        case "서":
            self.directionImage.image = UIImage(named: self.directionImages[2])!
        case "남서":
            self.directionImage.image = UIImage(named: self.directionImages[3])!
        case "남":
            self.directionImage.image = UIImage(named: self.directionImages[4])!
        case "남동":
            self.directionImage.image = UIImage(named: self.directionImages[5])!
        case "동":
            self.directionImage.image = UIImage(named: self.directionImages[6])!
        case "북동":
            self.directionImage.image = UIImage(named: self.directionImages[7])!
        default:
            break
        }
        self.directionImage.reloadInputViews()
        
        self.temparature.text = String(format: "%.1f°C", newest.temp)
        self.temparature.reloadInputViews()
        self.windspeed.text = String(format: "%.1fm/s", newest.ws)
        self.windspeed.reloadInputViews()
        self.humidity.text = String(format: "%d%%", newest.reh)
        self.windspeed.reloadInputViews()
        self.chanceOfRain.text = String(format: "%d%%", newest.pop)
        self.chanceOfRain.reloadInputViews()
        
        self.reloadInputViews()
        
    }
    
    func parseJson(data : Data) -> [ItemAddress] {
        var array = [ItemAddress]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [AnyObject]
            for element in jsonResult! {
                let item  = ItemAddress()
                item.code = element["code"] as! String
                item.value = element["value"] as! String
                array.append(item)
            }
        }
        catch {
            let errorMessage : String = String(format: "Error: %@", error.localizedDescription)
            let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            errorAlertController.addAction(cancelAction)
            self.present(errorAlertController, animated: true, completion: nil)
        }
        return array
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
