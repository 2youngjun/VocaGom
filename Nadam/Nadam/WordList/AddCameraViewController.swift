//
//  AddCameraViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/23.
//

import UIKit

class AddCameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLayout()

    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
    }
    
    private func configureLayout() {
        self.nextButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        self.nextButton.sizeToFit()
        
        self.cancelButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        
        self.titleLabel.font = UIFont.NFont.addWordNavigationTitle
    }
    
    
    
}
