//
//  BicycleLoginViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 12..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class BicycleLoginViewController: UIViewController, UIAlertViewDelegate{

    @IBOutlet weak var loginButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginButton.clipsToBounds = true
        loginButton.layer.cornerRadius = 12
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: AnyObject) {
        let session: KOSession = KOSession.shared();
        
        if session.isOpen() {
            session.close()
        }
        
        session.presentingViewController = self.navigationController
        session.open(completionHandler: { (error) -> Void in
            session.presentingViewController = nil
            
            if !session.isOpen() {
                switch ((error as! NSError).code) {
                    case Int(KOErrorCancelled.rawValue):
                        break;
                    default:
                        UIAlertView(title: "에러", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "확인").show()
                        break;
                }
            }
            if error != nil {
                self.appDelegate.requestMe()
            }
        }, authParams: nil, authTypes: [NSNumber(value: KOAuthType.talk.rawValue), NSNumber(value: KOAuthType.account.rawValue)])
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
