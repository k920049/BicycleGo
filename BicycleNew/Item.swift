//
//  Item.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 1..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation

class Item {
    var title : String
    var imageUrl : String
    var address : String
    var streetAddress : String
    var zipCode : String
    var phone : String
    var latitude : Double
    var longitude : Double
    var distance : Double
    var category : String
    var id : String
    var placeUrl : String
    var direction : String
    var addressBCode : String
    
    init() {
        self.title = ""
        self.imageUrl = ""
        self .address = ""
        self.streetAddress = ""
        self.zipCode = ""
        self.phone = ""
        self.latitude = 0
        self.longitude = 0
        self.distance = 0
        self.category = ""
        self.id = ""
        self.placeUrl = ""
        self.direction = ""
        self.addressBCode = ""
    }
    
    init(title : String,
         imageUrl : String,
         address : String,
         streetAddress : String,
         zipCode : String,
         phone : String,
         latitude : Double,
         longitude : Double,
         distance : Double,
         category : String,
         id : String,
         placeUrl : String,
         direction : String,
         addressBCode : String) {
        
        self.title = title
        self.imageUrl = imageUrl
        self .address = address
        self.streetAddress = streetAddress
        self.zipCode = zipCode
        self.phone = phone
        self.latitude = latitude
        self.longitude = longitude
        self.distance = distance
        self.category = category
        self.id = id
        self.placeUrl = placeUrl
        self.direction = direction
        self.addressBCode = addressBCode
    }
}
