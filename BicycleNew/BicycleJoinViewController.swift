//
//  MainViewController.swift
//  BicycleTest01
//
//  Created by 이 건준 on 2016. 11. 30..
//  Copyright © 2016년 SSU. All rights reserved.
//

import UIKit

class BicycleJoinViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var nameText : UITextField?
    @IBOutlet var ageText : UITextField?
    @IBOutlet var sexText : UITextField?
    @IBOutlet var weightText : UITextField?
    @IBOutlet var imageView : UIImageView?
    @IBOutlet var manButton : UIButton?
    @IBOutlet var womanButton : UIButton?
    let mainstoryboard = UIStoryboard(name: "Main", bundle: nil)
    var naviController:UINavigationController?
    var strBase64:String = ""
    
    
    fileprivate var doneSignup:Bool = false
    fileprivate var user:KOUser? = nil
    
    
    
    var sex:Int = 0;
    var idCheck:Bool = false;
    var lastId:String="";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "회원 가입"
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(BicycleJoinViewController.tappedMe))
        imageView?.addGestureRecognizer(tap)
        imageView?.isUserInteractionEnabled = true
        
        //self.hideKeyboardWhenTappedAround()
        requestMe()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    fileprivate func showErrorMessage(_ error: NSError) {
        if error.code == Int(KOErrorCancelled.rawValue) {
            UIAlertView.showMessage("에러! 다시 로그인해주세요!")
        } else {
            let description = error.userInfo[NSLocalizedDescriptionKey] as? String;
            UIAlertView.showMessage(NSString(format: "에러! code=%d, msg=%@", error.code, (description != nil ? description: "unknown error")!) as String)
        }
    }
    
    
    
    @IBAction func manClick(_ sender: AnyObject) {
        sex = 0;
        manButton?.backgroundColor = UIColor(red: 147.0/255.0, green: 228.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        womanButton?.backgroundColor = UIColor(red: 184.0/255.0, green: 184.0/255.0, blue: 184.0/255.0, alpha: 1.0)
    }
    
    @IBAction func womanClick(_ sender: AnyObject) {
        sex = 1;
        womanButton?.backgroundColor = UIColor(red: 147.0/255.0, green: 228.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        manButton?.backgroundColor = UIColor(red: 184.0/255.0, green: 184.0/255.0, blue: 184.0/255.0, alpha: 1.0)
    }
    
    func tappedMe()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView?.image = selectedImage
            imageView?.contentMode = .scaleAspectFill
            //imageView?.clipsToBounds = true
            
            let imageData:Data = UIImagePNGRepresentation(selectedImage)!
            
            //strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            strBase64 = imageData.base64EncodedString()
            
            
        }else{
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     override func viewDidDisappear(_ animated: Bool) {
     KOSession.shared().logoutAndClose { [weak self] (success, error) -> Void in
     _ = self?.navigationController?.popViewController(animated: true)
     }
     }
     */
    
    
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
            }
        }
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        
        let myUrl = URL(string: "http://kirkee2.cafe24.com/SignUp.php");
        
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"// Compose a query string
        
        if let id = nameText?.text {
            if(idCheck){
                if(lastId == id){
                    var ageString:String = (ageText?.text)!
                    var weightString:String = (weightText?.text)!
                    var age:Int
                    var weight:Int
                    var sexString:String
                    
                    if(ageString.characters.count == 0){
                        UIAlertView.showMessage("나이를 적어주세요.")
                        return;
                    }else if(weightString.characters.count == 0){
                        UIAlertView.showMessage("몸무게를 적어주세요.")
                        return;
                    }else{
                        if let ageTmp = Int(ageString){
                            age = ageTmp
                        }else{
                            UIAlertView.showMessage("나이는 숫자로만 이뤄져야합니다.")
                            
                            return;
                        }
                        
                        if let weightTmp = Int(weightString){
                            weight = weightTmp
                        }else{
                            UIAlertView.showMessage("몸무게는 숫자로만 이뤄져야합니다.")
                            return;
                        }
                        
                        if(age < 5 || age > 100){
                            UIAlertView.showMessage("나이는 5세 이상 100세 이하까지만 됩니다.")
                            return;
                        }else if(weight < 25 || weight > 150){
                            UIAlertView.showMessage("몸무게는 25이상 150이하까지만 됩니다.")
                            return;
                        }
                        
                        if(sex == 0){
                            sexString = "man"
                        }else{
                            sexString = "woman"
                        }
                        
                        if(self.strBase64.characters.count == 0){
                            UIAlertView.showMessage("사진을 선택해주세요.")
                            return;
                        }
                        
                        //let strBase64:String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                        
                        //UIAlertView.showMessage("{\"kakao\":\"\((self.user!.id)!)\",\"id\":\"\(id)\",\"age\":\"\(age)\",\"weight\":\"\(weight)\",\"sex\":\"\(sexString)\",\"image\":\"\(strBase64)\"}")
                        
                        //print("인코드 ====== \(strBase64)")
                        
                        
                        
                        print("id:\(id)")
                        let jsonString = "{\"kakao\":\"\((self.user!.id)!)\",\"id\":\"\(id)\",\"age\":\"\(age)\",\"weight\":\"\(weight)\",\"sex\":\"\(sexString)\",\"image\":\"\(strBase64)\"}"
                        
                        //let jsonString = "{\"kakao\":\"\((self.user!.id)!)\",\"id\":\"\(id)\",\"age\":\"\(age)\",\"weight\":\"\(weight)\",\"sex\":\"\(sexString)\",\"image\":\"asd\"}"
                        
                        //print(jsonString)
                        request.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
                        
                        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                            
                            if error != nil
                            {
                                
                                OperationQueue.main.addOperation {
                                    UIAlertView.showMessage("수행 도중 에러가 났습니다. 다시 한번 시도해주세요.")
                                }
                                
                                return
                            }
                            
                            // You can print out response object
                            //print("response = \(response)")
                            
                            //Let's convert response sent from a server side script to a NSDictionary object:
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                
                                if let parseJSON = json {
                                    
                                    // Now we can access value of First Name by its key
                                    let codeRespond:String = parseJSON["code"] as! String
                                    
                                    if(Int(codeRespond)! == 1){
                                        let errorRespond = parseJSON["error"] as! String
                                        print("signup code : \(codeRespond)")
                                        print("signup error : \(errorRespond)")
                                        
                                        if(Int(errorRespond)! == 0){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("아이디를 적어주세요.")
                                            }
                                        }else if(Int(errorRespond)! == 1){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("나이를 적어주세요.")
                                            }
                                        }else if(Int(errorRespond)! == 2){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("몸무게를 적어주세요.")
                                            }
                                        }else if(Int(errorRespond)! == 3){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("성별을 정해주세요.")
                                            }
                                        }else if(Int(errorRespond)! == 4){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("이미지를 선택해주세요.")
                                            }
                                        }else if(Int(errorRespond)! == 5){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("아이디에 사용하실수 없는 문자가 들어갔습니다.")
                                            }
                                        }else if(Int(errorRespond)! == 6){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("아이디는 최소 하나의 영문자를 포함해야합니다.")
                                            }
                                        }else if(Int(errorRespond)! == 7){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("중복된 아이디가 있습니다.")
                                            }
                                        }else if(Int(errorRespond)! == 8){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("중복된 카카오 아이다가 있습니다.")
                                            }
                                        }else if(Int(errorRespond)! == 9){
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("서버에서 오류가 났습니다. 다시 시도해주세요.")
                                            }
                                        }else{
                                            OperationQueue.main.addOperation {
                                                UIAlertView.showMessage("수행 도중 에러가 났습니다. 다시 한번 시도해주세요.")
                                            }
                                        }
                                    }else{
                                        print("signup code : \(codeRespond)")
                                        OperationQueue.main.addOperation {
                                            UIAlertView.showMessage("회원가입에 성공하셨습니다.")
                                            
                                            print("회원가입 성공")
                                            let mainViewController = self.mainstoryboard.instantiateViewController(withIdentifier: "RevealView")
                                            self.present(mainViewController, animated: true, completion: nil)
                                        }
                                    }
                                }
                            } catch {
                                print(error)
                            }
                        }
                        task.resume()
                    }
                }else{
                    UIAlertView.showMessage("아이디 중복확인을 해주세요.")
                    return;
                }
            }else{
                UIAlertView.showMessage("아이디 중복확인을 해주세요.")
                return;
            }
        }
    }
    
    
    
    @IBAction func checkId(_ sender: AnyObject) {
        
        /*
         let request = NSMutableURLRequest(url: NSURL(string: "http://kirkee2.cafe24.com/IdCheck.php")! as URL,cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 5)
         var response: URLResponse?
         
         // create some JSON data and configure the request
         let jsonString = "json={\"id\":\"asd\"}"
         request.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
         request.httpMethod = "POST"
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         
         // send the request
         do {
         
         try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
         } catch {
         print(error)
         }
         
         // look at the response
         if let httpResponse = response as? HTTPURLResponse {
         print("HTTP response: \(httpResponse.statusCode)")
         print("asd : \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
         } else {
         print("No HTTP response")
         }
         
         */
        
        
        let myUrl = URL(string: "http://kirkee2.cafe24.com/IdCheck.php");
        
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"// Compose a query string
        
        
        
        if let id = nameText?.text {
            if(id.characters.count==0){
                
                UIAlertView.showMessage("아이디를 적어주세요.")
                
            }else{
                let jsonString = "{\"id\":\"\(id)\"}"
                
                request.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
                
                let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                    
                    if error != nil
                    {
                        print("error=\(error)")
                        
                        OperationQueue.main.addOperation {
                            UIAlertView.showMessage("수행 도중 에러가 났습니다. 다시 한번 시도해주세요.")
                        }
                        
                        return
                    }
                    
                    // You can print out response object
                    //print("response = \(response)")
                    
                    //Let's convert response sent from a server side script to a NSDictionary object:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        if let parseJSON = json {
                            
                            // Now we can access value of First Name by its key
                            let codeRespond:String = parseJSON["code"] as! String
                            
                            if(Int(codeRespond)! == 1){
                                let errorRespond = parseJSON["error"] as! String
                                
                                if(Int(errorRespond)! == 0){
                                    OperationQueue.main.addOperation {
                                        UIAlertView.showMessage("아이디를 적어주세요.")
                                        
                                    }
                                }else if(Int(errorRespond)! == 1){
                                    OperationQueue.main.addOperation {
                                        UIAlertView.showMessage("해당 아이디가 이미 존재합니다.")
                                        
                                    }
                                }else if(Int(errorRespond)! == 2){
                                    OperationQueue.main.addOperation {
                                        UIAlertView.showMessage("사용하실수 없는 문자가 들어갔습니다.")
                                        
                                    }
                                }else if(Int(errorRespond)! == 3){
                                    OperationQueue.main.addOperation {
                                        UIAlertView.showMessage("아이디는 6자 이상 15자 이하여야합니다.")
                                        
                                    }
                                }else if(Int(errorRespond)! == 4){
                                    OperationQueue.main.addOperation {
                                        UIAlertView.showMessage("아이디는 최소 하나의 영문자를 포함해야합니다.")
                                    }
                                }else{
                                    OperationQueue.main.addOperation {
                                        UIAlertView.showMessage("수행 도중 에러가 났습니다. 다시 한번 시도해주세요.")
                                    }
                                }
                            }else{
                                OperationQueue.main.addOperation {
                                    UIAlertView.showMessage("사용 가능한 아이디입니다.")
                                }
                                
                                /*
                                 DispatchQueue.main.async(){
                                 //self.navigationController?.pushViewController(NewController(),animated:false)
                                 }
                                 */
                                
                                
                                self.idCheck = true;
                                self.lastId = id;
                                
                            }
                            //let errorRespond = parseJSON["error"] as! String
                            
                            
                            //print("firstNameValue: \(codeRespond) asdsa \(errorRespond)")
                        }
                    } catch {
                        print(error)
                    }
                }
                task.resume()
            }
        } else {
            print("값이 nil입니다.")
        }
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
