//
//  ItemAddress.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 1..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation

class ItemAddress {
    var code : String = ""
    var value : String = ""
    
    init() {
        self.code = ""
        self.value = ""
    }
    
    init(code : String, value : String) {
        self.code = code
        self.value = value
    }
}
