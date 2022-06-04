//
//  ViewController.swift
//  OutfitGenerator
//
//  Created by Ashley Smith on 2/18/22.
//

import UIKit
import PhotosUI
import CoreML
import Vision

class ViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var shoesImageView: UIImageView!
    @IBOutlet weak var shirtImageView: UIImageView!
    @IBOutlet weak var pantsImageView: UIImageView!
    var clothing = Clothing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addClothesButton(_ sender: UIBarButtonItem) {
       pickPhotos()
    }
    
    @IBAction func randomizeButton(_ sender: UIBarButtonItem) {
        if let shirtString = clothing.shirtArray?.randomElement() {
            shirtImageView.image = loadImageFromDiskWith(fileName: shirtString)
        }
        if let pantsString = clothing.pantsArray?.randomElement() {
            pantsImageView.image = loadImageFromDiskWith(fileName: pantsString)
        }
        if let shoesString = clothing.shoesArray?.randomElement() {
            shoesImageView.image = loadImageFromDiskWith(fileName: shoesString)
        }
    }
    
    // MARK: - PHPickerViewController
        
    @objc func pickPhotos() {
            var config = PHPickerConfiguration()
            config.selectionLimit = 25
            config.filter = PHPickerFilter.images
            let pickerViewController = PHPickerViewController(configuration: config)
            pickerViewController.delegate = self
            self.present(pickerViewController, animated: true, completion: nil)
        }
    
    // MARK: - PHPickerViewControllerDelegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        for result in results {
               result.itemProvider.loadObject(ofClass: UIImage.self) {(object, error) in
                   if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        guard let fileName = result.itemProvider.suggestedName else {
                            fatalError("Could not retrieve file name.")
                        }
                        guard let ciImage = CIImage(image: image) else {
                            fatalError("Could not convert to CI Image.")
                        }
                        self.saveImage(fileName: fileName, image: image)
                        self.detect(image: ciImage, fileName: fileName)
                    }
                }
            }
        }
    }
    
   // MARK: - CoreML Processing
    
    func detect(image: CIImage, fileName: String) {
        guard let model = try? VNCoreMLModel(for: ClothingClassifier(configuration: MLModelConfiguration()).model) else {
            fatalError("CoreML Model failed to load.")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("CoreML Model failed to process image.")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains(K.shirts) {
                    self.clothing.shirtArray?.append(fileName)
                } else if firstResult.identifier.contains(K.pants){
                    self.clothing.pantsArray?.append(fileName)
                } else if firstResult.identifier.contains(K.shoes) {
                    self.clothing.shoesArray?.append(fileName)
                }
                self.clothing.saveClothes()
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
        try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    //MARK: - Save/Load Image
    
    func saveImage(fileName: String, image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { fatalError("Could not retrieve document directory.")
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else {
            fatalError("Could not retrieve image jpeg data.")
        }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("Couldn't remove file at path", removeError)
            }
        }
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("Error saving file with error", error)
        }
    }

    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        return nil
    }
}
   
    



