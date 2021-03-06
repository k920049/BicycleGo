//
//  BicycleAVCameraViewController.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 10..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit
import AVFoundation

class BicycleAVCameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    fileprivate var user : KOUser?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 245/255, blue: 255/255, alpha: 1.0)
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType:
            AVMediaTypeVideo)
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        // Start video capture.
        captureSession?.startRunning()
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: topbar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects
        metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as!
        AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            if metadataObj.stringValue != nil {
                self.user = self.appDelegate.user
                
                if self.user != nil {
                    let bodyString = String(format: "{\"kakao\":\"%@\",\"auth\" : \"%@\" }", (self.user?.id)!, metadataObj.stringValue)
                    
                    let queryString = "http://kirkee2.cafe24.com/AuthCheck.php"
                    let queryUrl = URL(string: queryString)
                    var queryRequest = URLRequest(url: queryUrl!)
                    queryRequest.httpMethod = "POST"
                    queryRequest.httpBody = bodyString.data(using: .utf8)
                    
                    let queryTask = URLSession.shared.dataTask(with: queryRequest, completionHandler: {(data, response, error) -> Void in
                        
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
                        print(String(data: data, encoding: .utf8))
                        DispatchQueue.main.async {
                            self.messageLabel.text = "인증완료"
                        }
                        
                    })
                    queryTask.resume()
                }
            }
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
