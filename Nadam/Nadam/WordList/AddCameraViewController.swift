//
//  AddCameraViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/23.
//

import UIKit

class AddCameraViewController: UIViewController {

    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cameraView.image = picture
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    var picture: UIImage?
    
    @IBOutlet weak var shootButton: UIButton!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func tapShootButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapSearchButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let wordListViewController = segue.destination as? WordListViewController {
            wordListViewController.delegate = self
        }
    }
    
    private func configureLayout() {
        self.nextButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        self.nextButton.sizeToFit()
        
        self.cancelButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        
        self.titleLabel.font = UIFont.NFont.addWordNavigationTitle
        
        self.cameraView.layer.borderWidth = 1.0
        
        self.shootButton.layer.borderWidth = 1.0
        self.shootButton.layer.cornerRadius = 10.0
        
        self.searchButton.layer.borderWidth = 1.0
        self.searchButton.layer.cornerRadius = 10.0
        
    }
    
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
    
}

extension AddCameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
