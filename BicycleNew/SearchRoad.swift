//
//  SearchRoad.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 13..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation

class SearchRoad {
    var group = DispatchGroup()
    var data : Data?
    
    func search() -> Data? {
        return self._search()
    }
    
    fileprivate func _search() -> Data? {
        let searchURLString = "http://kirkee2.cafe24.com/RoadInfo.php"
        let searchURL = URL(string: searchURLString)
        let searchRequest = URLRequest(url: searchURL!)
        group.enter()
        let searchTask = URLSession.shared.dataTask(with: searchRequest, completionHandler: {(data, response, error) -> Void in
            guard let _data = data else {
                if let error = error {
                    let errorMessage : String = String(format: "Error: %@", error.localizedDescription)
                    let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    errorAlertController.addAction(cancelAction)
                    errorAlertController.show()
                }
                return
            }
            self.data = _data
            print(String(data: _data, encoding: .utf8))
            self.group.leave()
        })
        searchTask.resume()
        group.wait()
        if let _data = self.data {
            return _data
        } else {
            return nil
        }
    }
}
