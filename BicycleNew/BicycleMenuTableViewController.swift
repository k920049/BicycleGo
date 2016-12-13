//
//  BicycleMenuTableViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 3..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class BicycleMenuTableViewController: UITableViewController {
    fileprivate var user : KOUser? = nil
    let group = DispatchGroup()
    var userImage : UIImage? = nil
    @IBOutlet var Image : UIImageView!
    @IBOutlet var idLabel : UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.requestMe()
        if let _user = self.user {
            let ID = String(format: "%d", _user.id)
            self.idLabel.text = ID
            
            let requestURLString = String(format: "kirkee2.cafe24.com/memberImage/%@.jpg", ID)
            let searchUrl = URL(string: requestURLString)
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
                if let userImageData = Data(base64Encoded: _data) {
                    self.userImage = UIImage(data: userImageData)
                }
                self.group.leave()
            })
            searchTask.resume()
            self.group.wait()
            if let _userImage = self.userImage {
                self.Image.image = _userImage
            }
        }
    }
    
    fileprivate func requestMe(_ displayResult: Bool = false) {
        KOSessionTask.meTask { [weak self] (user, error) -> Void in
            if error != nil {
                UIAlertView.showMessage((error?.localizedDescription)!)
            } else {
                if displayResult {
                    UIAlertView.showMessage((user as! KOUser).description);
                }
                
                self?.user = (user as! KOUser)
            }
        }
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
