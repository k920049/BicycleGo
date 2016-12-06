//
//  BicycleNavigationControllerExtension.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 11. 30..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func addSideBarMenu(leftMenuButton: UIBarButtonItem?, rightMenuButton:
        UIBarButtonItem? = nil) {
        if revealViewController() != nil {
            if let menuButton = leftMenuButton {
                menuButton.target = revealViewController()
                menuButton.action =
                    #selector(SWRevealViewController.revealToggle(_:))
            }
            if let extraButton = rightMenuButton {
                revealViewController().rightViewRevealWidth = 150
                extraButton.target = revealViewController()
                extraButton.action =
                    #selector(SWRevealViewController.rightRevealToggle(_:))
            }
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
