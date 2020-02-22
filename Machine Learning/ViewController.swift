//
//  ViewController.swift
//  Machine Learning
//
//  Created by VincentL on 3/23/19.
//  Copyright © 2019 VincentL. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var indexLabel: UILabel!
    
//    var classificationResults : [String] = []
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isHidden = true
        indexLabel.isHidden = true
        imagePicker.delegate = self
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Method 1:
        //        let image_data = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        //        let imageData:Data = image_data!.pngData()!
        //        let imageStr = imageData.base64EncodedString()
        //
        //        imageView.image = image_data
        //        imagePicker.dismiss(animated: true, completion: nil)
        
        //Method 2:
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = pickedImage
            imagePicker.dismiss(animated: true, completion: nil)
            
            guard let ciimage = CIImage(image: pickedImage) else {
                fatalError("CII Cnovert failed")
            }
            detect(image: ciimage)
        }
        
        
    }//done when finishing picking image
    
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{    //optional if success, nil if fail
            fatalError("Loading CoreML Model Failed.")
            
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results?.first as? VNClassificationObservation else{
                fatalError("Model failed to process image")
            }
            print(results)
            let index = results.confidence

            self.indexLabel.isHidden = false
            self.indexLabel.text = "Confidence:\(index)"
            self.navigationItem.title = results.identifier.capitalized

            
//            if let firstResult = results.first {
//
//                if firstResult.identifier.contains("hotdog") {
//                    self.navigationItem.title = "Hotdog!"
//                    self.shareButton.isHidden = false
//                    self.navigationController?.navigationBar.barTintColor = UIColor.green
//                    self.navigationController?.navigationBar.isTranslucent = false
//                } else{
//                    self.shareButton.isHidden = true
//                    self.navigationItem.title = "Not Hotdag!"
//                    self.navigationController?.navigationBar.barTintColor = UIColor.red
//                    self.navigationController?.navigationBar.isTranslucent = false
//                }
//
//            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
//        imagePicker.sourceType = .photoLibrary
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func photoLibraryTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title)")
//            vc?.add(imageView)
            
        }else{
            self.navigationItem.title = "Please log in to Twitter"
        }
    }
}

