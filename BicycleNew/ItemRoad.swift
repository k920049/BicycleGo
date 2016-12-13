//
//  ItemRoad.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 13..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation

@objc class ItemRoad : NSObject {
    
    var id : String?
    var title : String?
    var startLatitude : Double?
    var startLongitude : Double?
    var endLatitude : Double?
    var endLongitude : Double?
    var authCenter : [(Double, Double)]?
    
    init(id : String?, title : String?,
         startLatitude : Double?, startLongitude : Double?,
         endLatitude : Double?, endLongitude : Double?,
         authCenter : [(Double, Double)]?) {
        self.id = id
        self.title = title
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
        self.authCenter = authCenter
    }
    
    
}
