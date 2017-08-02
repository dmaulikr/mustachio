//
//  ViewController.swift
//  SeeFood Clone
//
//  Created by Seth Carrino on 8/2/17.
//  Copyright © 2017 Seth Carrino. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let apiKey = "2913453cd0ec1b7e5eda9c606828459529f9f4d4"
    let version = "2017-08-02"
    
    @IBOutlet weak var shareButton: UIImageView!
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
   
    
    
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isHidden = true
        imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
                
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].classification)
                }
                
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                
                if self.classificationResults.contains("mustachio") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Perfect Mustachio!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "heart")
                    }
                    
                }
                    
                else{
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Needs more Mustachio!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "mustache")
                       
                    }
                    
                }
                
                
                
            })
            
            
            
            
            
        } else {
            
            print("There was an error picking the image");
            
        }
        
        
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText(navigationItem.title)
            present(vc!, animated: true, completion: nil)
            
        } else {
            
            self.navigationItem.title = "Login to Twitter"
            
        }
        
    }
    
}

