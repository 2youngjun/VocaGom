//
//  AddCameraViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/23.
//

import UIKit
import Vision
import Foundation

class AddCameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLayout()
//        self.makeDelegateSelf()
        
//        self.cameraView.image = sentImage
        self.nextButton.isEnabled = false
        
        if cameraView.image == nil {
            print("🐰")
        } else {
            self.cameraView.image = sentImage
            self.cameraView.contentMode = .scaleAspectFit
        }
        
        self.recognizeText(image: self.cameraView.image ?? UIImage())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.recognizeText(image: self.cameraView.image ?? UIImage())
        print(textSet)
    }
    
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var cameraSectionTitle: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var searchedWordTitle: UILabel!
    @IBOutlet weak var cameraViewHeight: NSLayoutConstraint!
    
    var sentImage: UIImage?
    var textSet: [String] = []
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        
    }
    
    @IBAction func tapCameraButton(_ sender: Any) {
        
    }
    @IBAction func tapPresentCameraButton(_ sender: UIButton) {
        self.presentCamera()
    }
    
    private func configureLayout() {
        self.nextButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        self.nextButton.titleLabel?.sizeToFit()
        
        self.cancelButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        self.cancelButton.titleLabel?.sizeToFit()
        
        self.titleLabel.font = UIFont.NFont.addWordNavigationTitle
        
        self.cameraSectionTitle.font = UIFont.NFont.wordListWordMeaning
        self.cameraSectionTitle.sizeToFit()
        
        self.cameraView.image = UIImage(systemName: "camera")
        self.cameraViewHeight.constant = UIScreen.main.bounds.height / 3
        self.cameraView.layer.borderWidth = 1.0
        
        self.cameraButton.titleLabel?.textColor = UIColor.NColor.blue
        self.cameraButton.titleLabel?.font = UIFont.NFont.wordListWordMeaning
        self.cameraButton.layer.cornerRadius = self.cameraButton.frame.height / 2
        
        self.searchedWordTitle.font = UIFont.NFont.wordListWordMeaning
    }
    
    private func recognizeText(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
            }
            
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string.lowercased().replacingOccurrences(of: "[^a-zA-Z ]", with: "", options: .regularExpression)
            }).joined(separator: ", ")
            
            var modifyingText = text.components(separatedBy: [",", " "])
            
            while modifyingText.contains("") {
                if let index = modifyingText.firstIndex(of: "") {
                    modifyingText.remove(at: index)
                }
            }
            
//            DispatchQueue.main.async {
//                self?.textSet = modifyingText
//            }
            self?.textSet = modifyingText

        }
        
        do {
            request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
            request.recognitionLanguages = ["en"]
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

extension AddCameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private func presentCamera() {
        #if targetEnvironment(simulator)
        fatalError()
        #endif
        
        DispatchQueue.main.async {
            let pickerController = UIImagePickerController() // must be used from main thread only
            pickerController.sourceType = .camera
            
            pickerController.allowsEditing = false
            
            pickerController.mediaTypes = ["public.image"]
            
            pickerController.delegate = self
            
            self.present(pickerController, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        self.cameraView.image = image
        self.cameraView.contentMode = .scaleAspectFit
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddCameraViewController: CameraPictureDelegate {
    func sendCameraPicture(picture: UIImage) {
        self.sentImage = picture
    }
}
