//
// 
// FileName: ViewController.swift
// ProjectName: SeaFood
//
// Created by MD ABIR HOSSAIN on 16-11-2024 at 11:54 PM
// Website: https://mdabirhossain.com/
//


import UIKit
import PhotosUI
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var outputLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    let photoPicker = PHPickerViewController.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
//        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        outputLabel.text = ""
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let cIImage = CIImage(image: userPickedImage) else {
                fatalError("Couldn't convert UIImage to CIImage")
            }
            
            detect(image: cIImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: .init()).model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let reqest = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            print(result)
            self.outputLabel.text = result[0].identifier
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([reqest])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func galleryTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
}

