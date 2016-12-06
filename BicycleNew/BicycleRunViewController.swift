//
//  BicycleRunViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 3..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class BicycleRunViewController: UIViewController {
    @IBOutlet var menuItem : UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        manageHoler.checkForLocationAccess()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSideBarMenu(leftMenuButton: menuItem)

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 245/255, blue: 255/255, alpha: 1.0)
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
