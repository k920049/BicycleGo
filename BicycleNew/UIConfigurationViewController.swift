//
//  UIConfigurationViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 17..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class UIConfigurationViewController: UIViewController {
    @IBOutlet var menuItem : UIBarButtonItem!
    @IBOutlet var logoutButton : UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var user : KOUser?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSideBarMenu(leftMenuButton: menuItem)
        // Do any additional setup after loading the view.
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        if sender == logoutButton {
            
            let errorMessage = "If you log out, it means you need to open the application again. Are you sure you want to log out?"
            let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
            
                KOSession.shared().logoutAndClose { [weak self] (success, error) -> Void in
                    
                    _ = self?.navigationController?.popViewController(animated: true)
                }
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            errorAlertController.addAction(okAction)
            errorAlertController.addAction(cancelAction)
            
            self.present(errorAlertController, animated: true, completion: nil)
        }
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
