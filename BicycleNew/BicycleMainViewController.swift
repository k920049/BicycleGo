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

let manageHoler = ManagerHolder()

class BicycleMainViewController: UIViewController, CLLocationManagerDelegate {
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
    
    var DMapView : MTMapView?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var timer = Timer()
   
    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var prevlastLocation: CLLocation!
    var loc: CLLocation!
    var counter = 0
    var traveledDistance:Double = 0
    
    var weatherImages = ["Sunny", "PartlyCloudy", "Rain", "RainANDSnow"]
    var directionImages = ["North", "NorthEast", "East", "SouthEast", "South", "SouthWest", "West", "NorthWest"]
    
    @IBAction func buttonClicked(sender : UIButton) {
        
        if(sender == buttonPlay) {
            buttonPlay.isHidden = true
            speedometerView.isHidden = false
            startButton.isHidden = false
            endButton.isHidden = false
        } else if(sender == endButton) {
            buttonPlay.isHidden = false
            speedometerView.isHidden = true
            startButton.isHidden = true
            endButton.isHidden = true
            timer.invalidate()
            secondsToHoursMinutesSeconds(counter, result: { (h, m, s) in
                self.timeAccumulated.text = "\(self.timeText(h)):\(self.timeText(m)):\(self.timeText(s))"
            })
        } else if(sender == startButton) {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BicycleMainViewController.updateCounter), userInfo: nil, repeats: true)
        }
    }
    
    
    let REQ_ACC : CLLocationAccuracy = 100
    var shouldExecute : Bool = false
    
    var locman : CLLocationManager {
        return manageHoler.locman!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.locman.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.global(qos: .background).async {
                manageHoler.doThisWhenAuthorized?()
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if startLocation == nil {
            startLocation = locations.first
            lastLocation = locations.last
        } else {
            prevlastLocation = lastLocation
            lastLocation = locations.last
            let lastDistance = prevlastLocation.distance(from: lastLocation)
            traveledDistance += lastDistance
            distanceAccumulated.text = String(format: "%.1f m", traveledDistance)
            speedometerLabel.text = String(format: "%.1f Km/h", abs(lastLocation.speed) * 3600 / 1000)
        }

        let acc = lastLocation.horizontalAccuracy
        calori.text = String(acc)
        if acc >= 0 && acc < REQ_ACC {
            self.shouldExecute = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var _error : Bool = false
        
        self.locman.delegate = self
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.locman.desiredAccuracy = kCLLocationAccuracyBest
            self.locman.activityType = .fitness
            self.locman.distanceFilter = 2.0
            self.locman.startUpdatingLocation()
            
            while(true) {
                if(self.shouldExecute) {
                    break
                }
            }
            
            manageHoler.checkForLocationAccess(always: false, andThen: { () -> Void in
                
                if let DMapView = self.DMapView {
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
