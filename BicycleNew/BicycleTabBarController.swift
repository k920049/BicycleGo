//
//  BicycleTabBarController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 11. 30..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class BicycleTabBarController: UITabBarController {
    
    var currentBarIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.selectedIndex = currentBarIndex
        super.viewWillAppear(animated)
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