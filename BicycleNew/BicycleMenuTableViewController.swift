//
//  BicycleMenuTableViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 3..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class BicycleMenuTableViewController: UITableViewController {
    
    @IBOutlet var Image : UIImageView!
    @IBOutlet var idLabel : UILabel!
    
    fileprivate var user : KOUser? = nil
    let group = DispatchGroup()
    var userImage : UIImage? = nil
    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    var serviceID : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.user = self.appDelegate.user
        if let _user = self.user {
            if self.userImage == nil || self.serviceID == nil {
                let ID_IN_INT64 = Int64(_user.id)
                let ID = String(format: "%d", ID_IN_INT64)
                let requestURLStringImage = String(format: "http://kirkee2.cafe24.com/memberImage/%@.jpg", ID)
                let requestURLStringID = "http://kirkee2.cafe24.com/UserInfo.php"
                
                self.requestID(format: requestURLStringID, ID: ID)
                self.requestImage(format: requestURLStringImage)
            }
        }
    }
    
    fileprivate func requestImage(format : String) -> Void {
        
        let searchUrl = URL(string: format)
        let searchRequest = URLRequest(url: searchUrl!)
        self.group.enter()
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
            print(_data.base64EncodedData())
            let imageData = Data(base64Encoded: _data.base64EncodedData(), options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
            if let _imageData = imageData {
                self.userImage = UIImage(data: _imageData)
            }
            self.group.leave()
        })
        searchTask.resume()
        self.group.wait()
        if let _userImage = self.userImage {
            self.Image.image = _userImage
            self.Image.layer.cornerRadius = 32.0
            self.Image.clipsToBounds = true
        }
    }
    
    fileprivate func requestID(format : String, ID : String) -> Void {
        let searchUrl = URL(string: format)
        var searchRequest = URLRequest(url: searchUrl!)
        let httpBody = String(format: "{ \"kakao\" : \"%@\" }", ID)
        searchRequest.httpBody = httpBody.data(using: .utf8)
        searchRequest.httpMethod = "POST"
        
        self.group.enter()
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
            
            if let _data = data {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions.mutableContainers) as? AnyObject
                    let code = jsonResult?["code"] as? String
                    let id = jsonResult?["id"] as? String
                    if code != nil {
                        if id != nil {
                            self.serviceID = id!
                            self.idLabel.text = self.serviceID
                        }
                    }
                } catch {
                    print(error)
                }
            }
            self.group.leave()
        })
        searchTask.resume()
        group.wait()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
