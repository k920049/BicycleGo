//
//  UICertificationTableViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 17..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class UICertificationTableViewController: UITableViewController {

    @IBOutlet var menuItem : UIBarButtonItem!
   
    
    //        performSegue(withIdentifier: "showCamera", sender: self)

    
    var result : [ItemRoad]?
    var resultData : Data?
    let resultObject = SearchRoad()
    var selectedRow : Int = -1
    var authInfo = Array(repeating: 0 , count : 3);
    @IBOutlet var qrCode: UIImageView!
    
    fileprivate var doneSignup:Bool = false
    fileprivate var user:KOUser?
    var jsonString : String? = ""
    
    var rowTitle = [String]()
    var rowAuth = [String]()
    var rowId = [String]()
    var image = ["auth1.png","auth2.png","auth3.png"]
    
    
    override func viewWillAppear(_ animated: Bool) {
        requestMe()
    }
    
    
    func showMap() {
        performSegue(withIdentifier: "showCamera", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSideBarMenu(leftMenuButton: menuItem)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(showMap))
        qrCode.isUserInteractionEnabled = true
        qrCode.addGestureRecognizer(tapGestureRecognizer)
        
    
        
        //userAuthInfo()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "showCamera", sender: self)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "certCell", for: indexPath) as! UICertificationTableViewCell

        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            cell.titleLabel.text = self.rowTitle[indexPath.row]
            cell.titleImage?.image = UIImage(named: self.image[indexPath.row])
            
            if(self.rowAuth[indexPath.row] == "1"){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        })

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    fileprivate func showErrorMessage(_ error: NSError) {
        if error.code == Int(KOErrorCancelled.rawValue) {
            UIAlertView.showMessage("에러! 다시 로그인해주세요!")
        } else {
            let description = error.userInfo[NSLocalizedDescriptionKey] as? String;
            UIAlertView.showMessage(NSString(format: "에러! code=%d, msg=%@", error.code, (description != nil ? description: "unknown error")!) as String)
        }
    }
    
    fileprivate func requestMe(_ displayResult: Bool = false) {
        
        KOSessionTask.meTask { [weak self] (user, error) -> Void in
            
            if error != nil {
                self?.showErrorMessage(error as! NSError)
                self?.doneSignup = false
            } else {
                if displayResult {
                    UIAlertView.showMessage((user as! KOUser).description);
                }
                
                self?.doneSignup = true
                self?.user = (user as! KOUser)
                
                if let tmp = user{
                    self?.jsonString = "{\"kakao\":\"\((self?.user!.id!)!)\"}"
                }
                
                //self?.jsonString = "{\"kakao\":\"\((self?.user!.id!)!)\"}"

                
                self?.userAuthInfo()
            }
        }
    }
    
    func userAuthInfo(){
        let myUrl = URL(string: "http://kirkee2.cafe24.com/UserAuthInfo.php");
        
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"// Compose a query string
        
        //let jsonString = "{\"kakao\":\"\((self.user!.id!))\"}"
        
        
        request.httpBody = jsonString!.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        var group = DispatchGroup()
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        
            group.enter()
            
            if error != nil
            {
                print("error=\(error)")
                
                OperationQueue.main.addOperation {
                    UIAlertView.showMessage("수행 도중 에러가 났습니다. 다시 한번 시도해주세요.")
                }
                
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    
                    // Now we can access value of First Name by its key
                    let codeRespond:String = parseJSON["code"] as! String
                    
                    if(Int(codeRespond)! == 1){
                        
                    }else{
                        /*
                         OperationQueue.main.addOperation {
                         UIAlertView.showMessage("사용 가능한 아이디입니다.")
                         }
                         */
                        let auth1:String = parseJSON["auth1"] as! String
                        let auth2:String = parseJSON["auth2"] as! String
                        let auth3:String = parseJSON["auth3"] as! String
                        
                        if(auth1 == "0"){
                            self.rowAuth.append("0")
                        }else{
                            self.rowAuth.append("1")
                        }
                        
                        if(auth2 == "0"){
                            self.rowAuth.append("0")
                        }else{
                            self.rowAuth.append("1")
                        }
                        
                        if(auth3 == "0"){
                            self.rowAuth.append("0")
                        }else{
                            self.rowAuth.append("1")
                        }
                    
                        
                        print("\(self.rowAuth[0])   asdassd    \(self.rowAuth[1])   asdasd asdas \(self.rowAuth[2])")
                        print("\(self.rowAuth[0])   asdassd    \(self.rowAuth[1])   asdasd asdas \(self.rowAuth[2])")
                        print("\(self.rowAuth[0])   asdassd    \(self.rowAuth[1])   asdasd asdas \(self.rowAuth[2])")
                        print("\(self.rowAuth[0])   asdassd    \(self.rowAuth[1])   asdasd asdas \(self.rowAuth[2])")
                        print("\(self.rowAuth[0])   asdassd    \(self.rowAuth[1])   asdasd asdas \(self.rowAuth[2])")
                        print("\(self.rowAuth[0])   asdassd    \(self.rowAuth[1])   asdasd asdas \(self.rowAuth[2])")
                        
                        
                        self.AuthInfo();
                        /*
                         DispatchQueue.main.async(){
                         //self.navigationController?.pushViewController(NewController(),animated:false)
                         }
                         */
                        
                        
                    }
                    //let errorRespond = parseJSON["error"] as! String
                    
                    
                    //print("firstNameValue: \(codeRespond) asdsa \(errorRespond)")
                }
            } catch {
                print(error)
            }
            
            group.leave()
       
        }
        task.resume()
        
        group.wait()
    }

    func AuthInfo(){
        let myUrl = URL(string: "http://kirkee2.cafe24.com/AuthInfo.php");
        
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"// Compose a query string
        
        let tmpJsonString = "{\"hoho\":\"hoho\"}"
    
        
        request.httpBody = tmpJsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        var group = DispatchGroup()
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
           
        
            group.enter()
            
            if error != nil
            {
                print("error=\(error)")
                
                OperationQueue.main.addOperation {
                    UIAlertView.showMessage("수행 도중 에러가 났습니다. 다시 한번 시도해주세요.")
                }
                
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [AnyObject]
                
                let firstIndex = json?[0]
                
                if(firstIndex?["code"]! as! String == "0"){
                    for i in 1..<4 {
                        var tmp = json?[i]
                        
                        self.rowId.append(tmp?["id"]! as! String)
                        self.rowTitle.append(tmp?["title"]! as! String)
                        
                        print("asdasdasdsdasdasdasdsds asd \(self.rowId[i-1])")
                        print("asdasdasdsdasdasdasdsds asd \(self.rowTitle[i-1])")
                    }
                    
                }else{
                    
                }
                
                /*
                if let parseJSON = json?[0] {
                    
                    // Now we can access value of First Name by its key
                    let codeRespond:String = parseJSON["code"] as! String
                    
                    if(Int(codeRespond)! == 1){
                       
                    }else{
                        /*
                        OperationQueue.main.addOperation {
                            UIAlertView.showMessage("사용 가능한 아이디입니다.")
                        }
 */
                        
                        print(" asdassd       asdasd asdas ")
                        
                        /*
                         DispatchQueue.main.async(){
                         //self.navigationController?.pushViewController(NewController(),animated:false)
                         }
                         */
                        
                        
                    }
                    //let errorRespond = parseJSON["error"] as! String
                    
                    
                    //print("firstNameValue: \(codeRespond) asdsa \(errorRespond)")
                }
 */
 
 
            } catch {
                print(error)
            }
            
            group.leave()
        }
        task.resume()
        
        group.wait()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        rowAuth.removeAll()
        rowTitle.removeAll()
        rowId.removeAll()
    }
    
    
}

