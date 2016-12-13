//
//  BicycleRecommendTableViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 12..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit
import Darwin

class BicycleRecommendTableViewController: UITableViewController {
  
    var result : [ItemRoad]?
    var resultData : Data?
    let resultObject = SearchRoad()
    var selectedRow : Int = -1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.resultData = self.resultObject.search()
        if let _data = self.resultData {
            self.parseJSON(data: _data)
            if self.result != nil {
            } else {
                let errorAlertController = UIAlertController(title: "Error",
                                                             message: "Cannot parse json data",
                                                             preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                errorAlertController.addAction(cancelAction)
                self.present(errorAlertController, animated: true, completion: nil)
            }
        }
        self.tableView.rowHeight = CGFloat(80.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.result == nil {
            return 0
        } else {
             return (self.result?.count)!
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BicycleRecommendTableViewCell

        // Configure the cell...
        let _red = CGFloat(Double(arc4random_uniform(255)) / 255.0)
        let _green = CGFloat(Double(arc4random_uniform(255)) / 255.0)
        let _blue = CGFloat(Double(arc4random_uniform(255)) / 255.0)
        let imageColor = UIColor(red: _red,
                                 green: _green,
                                 blue: _blue,
                                 alpha: 1.0)
        
        cell.thumbnailImageView.layer.cornerRadius = 30.0
        cell.thumbnailImageView.clipsToBounds = true
        cell.thumbnailImageView.layer.backgroundColor = imageColor.cgColor
        cell.nameLabel.text = self.result?[indexPath.row].title
        if let _authCenter = self.result?[indexPath.row].authCenter {
            cell.locationLabel.text = String(_authCenter.count)
        } else {
            cell.locationLabel.text = String("0")
        }
        cell.typeLabel.text = self.result?[indexPath.row].id
        return cell
    }
 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showNavigation" {
            let dvc = segue.destination as! BicycleTabBarController
            dvc.currentBarIndex = 1
            dvc.setCurrentRoad(_currentRoad: self.result?[self.selectedRow])
            dvc.selectedIndex = 1
            dvc.view.setNeedsDisplay()
            self.selectedRow = -1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.result != nil {
            self.selectedRow = indexPath.row
            self.performSegue(withIdentifier: "showNavigation", sender: self)
        }
    }
 
    
    fileprivate func parseJSON(data : Data?) {
        if let _data = data {
            self.result = [ItemRoad]()
            do {
                let utf8EncodedString = String(data: _data, encoding: String.Encoding.utf8)
                let jsonResult = try JSONSerialization.jsonObject(with: (utf8EncodedString?.data(using: .utf8))!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [AnyObject]
                let firstIndex = jsonResult?[0]
                if firstIndex?["code"] as! String == "0" {
                    let dataArray = jsonResult?[1...(jsonResult?.endIndex)! - 1]
                    if let _dataArray = dataArray {
                        for element in _dataArray {
                            let authCenterString = element["authCenter"] as! String
                            var authCenterTupleArray : [(Double, Double)]?
                            if authCenterString == "0" {
                                authCenterTupleArray = nil
                            } else {
                                let authCenterArray = authCenterString.components(separatedBy: ";")
                                authCenterTupleArray = [(Double, Double)]()
                                for element in authCenterArray {
                                    let eachCoordinate = element.components(separatedBy: ",")
                                    let item = (Double(eachCoordinate[0])!, Double(eachCoordinate[1])!)
                                    authCenterTupleArray?.append(item)
                                }
                            }
                            
                            let item = ItemRoad(id: element["id"] as? String,
                                                title: element["title"] as? String,
                                                startLatitude: Double(element["startLatitude"] as! String),
                                                startLongitude: Double(element["startLongitude"] as! String),
                                                endLatitude: Double(element["endLatitude"] as! String),
                                                endLongitude: Double(element["endLongitude"] as! String),
                                                authCenter: authCenterTupleArray)
                            self.result?.append(item)
                        }
                    }
                }
            }
            catch {
                let errorMessage : String = String(format: "Error: %@", error.localizedDescription)
                let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                errorAlertController.addAction(cancelAction)
                self.present(errorAlertController, animated: true, completion: nil)
            }
        } else {
            self.result = nil
        }
        
    }
}
