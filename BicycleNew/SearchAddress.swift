//
//  SearchAddress.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 1..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation
import UIKit

var cityQueryFormat : String = "http://www.kma.go.kr/DFSROOT/POINT/DATA/top.json.txt"
var provinceQueryFormat : String = "http://www.kma.go.kr/DFSROOT/POINT/DATA/mdl.%@.json.txt"
var townQueryFormat : String = "http://www.kma.go.kr/DFSROOT/POINT/DATA/leaf.%@.json.txt"

class SearchAddress {
    
    var cityCode : String
    var provinceCode : String
    var townCode : String
    
    var mode : Int // 0 -> City, 1 -> Province, 2 -> Town
    
    init() {
        self.mode = -1
        
        self.cityCode = ""
        self.provinceCode = ""
        self.townCode = ""
    }
    
    init(mode : Int, addressCode : String) {
        
        self.mode = mode
     
        self.cityCode = ""
        self.provinceCode = ""
        self.townCode = ""
        
        switch mode {
        case 0:
            self.cityCode = addressCode
        case 1:
            self.provinceCode = addressCode
        case 2:
            self.townCode = addressCode
        default:
            let errorAlertController = UIAlertController(title: "Error",
                                                         message: "Invalid MODE",
                                                         preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            errorAlertController.addAction(cancelAction)
            errorAlertController.show()
            
        }
    }
    
    func setModeCity() -> Void {
        self.mode = 0
    }
    
    func setModeProvince(addressCode : String) -> Void {
        self.mode = 1
        self.cityCode = addressCode
    }
    
    func setModeTown(addressCode : String) -> Void {
        self.mode = 2
        self.provinceCode = addressCode
    }
    
    func search() -> Data? {
        
        var queryFormat : String = ""
        var error : Bool = false
        
        switch mode {
        case 0:
            queryFormat = cityQueryFormat
        case 1:
            if(cityCode.characters.count > 0) {
                queryFormat = String(format: provinceQueryFormat, cityCode)
            } else {
                error = true
                let errorAlertController = UIAlertController(title: "Error",
                                                             message: "Empty city code",
                                                             preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                errorAlertController.addAction(cancelAction)
                errorAlertController.show()
            }
        case 2:
            if(provinceCode.characters.count > 0) {
                queryFormat = String(format: townQueryFormat, provinceCode)
            } else {
                error = true
                let errorAlertController = UIAlertController(title: "Error",
                                                             message: "Empty province code",
                                                             preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                errorAlertController.addAction(cancelAction)
                errorAlertController.show()
            }
        default:
            let errorAlertController = UIAlertController(title: "Error",
                                                         message: "Invalid MODE",
                                                         preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            errorAlertController.addAction(cancelAction)
            errorAlertController.show()
        }
        
        if(!error) {
            return self._search(queryString: queryFormat)
        } else {
            return nil
        }
    }
    
    private func _search(queryString : String) -> Data? {
        
        var _data : Data?
        var _error : Bool = false
        var downloadGroup = DispatchGroup()
        
        guard let queryUrl = URL(string: queryString) else {
            let errorAlertController = UIAlertController(title: "Error", message: "While making URL", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            errorAlertController.addAction(cancelAction)
            errorAlertController.show()
            return nil
        }
        let request = URLRequest(url: queryUrl)
        downloadGroup.enter()
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let error = error {
                _error = true
                let errorMessage : String = String(format: "Error: %@", error.localizedDescription)
                let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                errorAlertController.addAction(cancelAction)
                errorAlertController.show()
            }
            
            guard let data = data else {
                _error = true
                let errorAlertController = UIAlertController(title: "Error",
                                                             message: "Data returned is nil",
                                                             preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                errorAlertController.addAction(cancelAction)
                errorAlertController.show()
                return
            }
            _data = data
            downloadGroup.leave()
        })
        task.resume()
        downloadGroup.wait()
    
        if(_error ) {
            return nil
        } else {
            return _data
        }
    }

}

