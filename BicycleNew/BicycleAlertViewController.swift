//
//  BicycleAlertViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 12..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation

import UIKit

extension UIAlertView {
    
    static func showMessage(_ message: String) {
        self.init(title: "", message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }
}
