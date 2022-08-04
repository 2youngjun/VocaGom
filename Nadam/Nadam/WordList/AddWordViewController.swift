//
//  AddWordViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import UIKit

class AddWordViewController: UIViewController {
    
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sheetPresentationController.detents = [.medium()]
        setLayoutStyle()
    }
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setLayoutStyle() {
        saveButton.titleLabel?.font = UIFont.NFont.addWordNavigationButton
        saveButton.sizeToFit()
        
        cancelButton.titleLabel?.font = UIFont.NFont.addWordNavigationButton
        cancelButton.sizeToFit()
        
        titleLabel.font = UIFont.NFont.addWordNavigationTitle
    }
}
