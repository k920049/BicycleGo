//
//  SearchKeyword.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 6..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation

let KEYWORD_SEARCH_FORMAT = "https://apis.daum.net/local/v1/search/keyword.json?query=%@&location=%f,%f&radius=%d&page=%d&apikey=%@"
let HTTP_FIELD_PLATFORM = "x-platform"
let HTTP_FIELD_APPID = "x-appid"

class SearchKeyword {
    var keyword : String?
    var latitude : Double?
    var longitude : Double?
    var radius : Int?
    
    var result : [Item]?
    
    init() {
        self.result = [Item]()
    }
    
    func setKeyword(keyword : String, latitude : Double, longitude : Double, radius : Int) {
        self.keyword = keyword
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    func search() -> [Item]? {
        if let keyword = self.keyword {
            return _search(keyword: keyword)
        } else {
            let errorAlertController = UIAlertController(title: "Error",
                                                         message: "No keyword set",
                preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            errorAlertController.addAction(cancelAction)
            errorAlertController.show()
            return nil
        }
    }
    private func _search(keyword : String) -> [Item]? {
        var group = DispatchGroup()
        
        let searchQuery = String(format: KEYWORD_SEARCH_FORMAT,
                                 self.keyword!,
                                 self.latitude!,
                                 self.longitude!,
                                 self.radius!,
                                 1,
                                 DMApiKey)
        let encodedData = searchQuery.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let bundleID = Bundle.main.bundleIdentifier
        let searchUrl = URL(string: encodedData!)
        var searchRequest = URLRequest(url: searchUrl!)
        searchRequest.setValue(bundleID, forHTTPHeaderField: HTTP_FIELD_APPID)
        searchRequest.setValue("ios", forHTTPHeaderField: HTTP_FIELD_PLATFORM)
        group.enter()
        let searchTask = URLSession.shared.dataTask(with: searchRequest, completionHandler: {(data, response, error) -> Void in
            
            guard let data = data else {
                if let error = error {
                    let errorMessage : String = String(format: "Error: %@", error.localizedDescription)
                    let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    errorAlertController.addAction(cancelAction)
                    errorAlertController.show()
                }
                return
            }
            print(String(data: data, encoding: String.Encoding.utf8))
            self.parseJson(data: data)
            group.leave()
        })
        searchTask.resume()
        
        group.wait()
        return self.result
    }
    
    func parseJson(data : Data) {
        self.result?.removeAll()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            let channel = jsonResult?["channel"] as! NSDictionary
            let items = channel["item"] as! [AnyObject]
            for element in items {
                let item = Item()
                item.title = element["title"] as! String
                item.latitude = Double(element["latitude"] as! String)!
                item.longitude = Double(element["longitude"] as! String)!
                
                self.result?.append(item)
            }
        }
        catch {
            let errorMessage : String = String(format: "Error: %@", error.localizedDescription)
            let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            errorAlertController.addAction(cancelAction)
            errorAlertController.show()
        }
    }
}
