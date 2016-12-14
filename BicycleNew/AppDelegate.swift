//
//  AppDelegate.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 11. 30..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


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
    
    /*
     ==================================================
                        AppDelegate
     ==================================================
     Made by : 건준
     Description : 
        * perform login process and determine whether to skip loading login page or not
     
    */
    var loginViewController: UIViewController?
    var mainViewController: UIViewController?
    var realMainViewController: UIViewController?
    var jsonString: String?
    
    var deviceToken: Data? = nil
    var user : KOUser?
    var doneSignup : Bool?
    
    fileprivate func requestMe(_ displayResult: Bool = false) {
        KOSessionTask.meTask { [weak self] (user, error) -> Void in
            if error != nil {
                self?.reloadRootViewController()
            } else {
                self?.doneSignup = true
                self?.user = (user as! KOUser)
                
                self?.jsonString = "{\"kakao\":\"\((self?.user!.id)!)\"}"
                
                self?.reloadRootViewController()
            }
        }
    }
    
    fileprivate func setupEntryController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "navigator") as! UINavigationController
        let navigationController2 = storyboard.instantiateViewController(withIdentifier: "navigator") as! UINavigationController
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "login") as UIViewController
        navigationController.pushViewController(viewController, animated: true)
        self.loginViewController = navigationController
        
        let viewController2 = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
        navigationController2.pushViewController(viewController2, animated: true)
        self.mainViewController = navigationController2
        
        self.realMainViewController = storyboard.instantiateViewController(withIdentifier: "RevealView")
    }
    
    fileprivate func reloadRootViewController() {
        let isOpened = KOSession.shared().isOpen()
        if !isOpened {
            let mainViewController = self.mainViewController as! UINavigationController
            
            let stack = mainViewController.viewControllers
            for i in 0 ..< stack.count {
                print(NSString(format: "[%d]: %@", i, stack[i] as UIViewController))
            }
            mainViewController.popToRootViewController(animated: true)
        }
        
        if(isOpened){
            print("4444")
            let myUrl = URL(string: "http://kirkee2.cafe24.com/CheckLogin.php");
            
            var request = URLRequest(url:myUrl!)
            
            request.httpMethod = "POST"// Compose a query string
            
            request.httpBody = jsonString?.data(using: String.Encoding.utf8, allowLossyConversion: true)
            
            let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil
                {
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    
                    if let parseJSON = json {
                        
                        // Now we can access value of First Name by its key
                        let codeRespond:String = parseJSON["code"] as! String
                        
                        if(Int(codeRespond)! == 1){
                            self.window?.rootViewController = self.mainViewController
                        }else{
                            DispatchQueue.main.async(){
                                self.window?.rootViewController?.present(self.mainViewController!, animated: true, completion: nil)
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
        }else{
            self.window?.rootViewController = self.loginViewController
        }
        
        self.window?.makeKeyAndVisible()
    }
    
    /*
     ==================================================
                        AppDelegate
     ==================================================
     Made by : 재성
     Description : 
        * inherit CLLocationManager's Delegate and implement some of the function inside
    */


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /*
         ==================================================
                    AppDelegate : application
         ==================================================
         Made by : 재성
         Description :
         * instantiate some of the initial settings of the application
         
         */
        
        /*
         ==================================================
         AppDelegate : application
         ==================================================
         Made by : 건준
         Description :
         * instantiate some of the initial settings of the application
         
         */
        setupEntryController()
        requestMe()
        
        /////////
        
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
    
        
        /*
         ==================================================
         AppDelegate : application
         ==================================================
         Made by : 건준
         Description :
         * instantiate some of the initial settings of the application
         
         */
        /*
        // 최초 실행시 2 종류의 rootViewController 를 준비한다.
        setupEntryController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.kakaoSessionDidChangeWithNotification), name: NSNotification.Name.KOSessionDidChange, object: nil)
        
        reloadRootViewController()
        
        // notification
        if #available(iOS 8.0, *) {
            let types: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications(matching: [UIRemoteNotificationType.badge, UIRemoteNotificationType.sound, UIRemoteNotificationType.alert])
        }
        
        let session = KOSession.shared()
        session?.presentedViewBarTintColor = UIColor(red: 0x2a / 255.0, green: 0x2a / 255.0, blue: 0x2a / 255.0, alpha: 1.0)
        session?.presentedViewBarButtonTintColor = UIColor(red: 0xe5 / 255.0, green: 0xe5 / 255.0, blue: 0xe5 / 255.0, alpha: 1.0)
        
        */
        return true
    }
    
    func kakaoSessionDidChangeWithNotification() {
        requestMe()
        //reloadRootViewController()
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        KOSession.handleDidEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        KOSession.handleDidBecomeActive()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let dic = userInfo["aps"] as? NSDictionary {
            let message: String = dic["alert"] as! String
            print("message=\(message)")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken
        print("didRegisterForRemoteNotificationsWithDeviceToken=\(deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError=\(error.localizedDescription)")
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        //MapleBaconStorage.sharedStorage.clearMemoryStorage()
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

