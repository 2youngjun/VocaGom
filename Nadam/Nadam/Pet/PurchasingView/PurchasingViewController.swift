//
//  PurchasingViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/10/02.
//

import UIKit

enum Clothes {
    case closet
    case sunglass
    case shirt
    case pants
    case shoes
}

class PurchasingViewController: UIViewController {
    
    //MARK: Variable
    var clothes: Clothes = .sunglass
    
    //MARK: IBOutlet Variable
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var buttonBackgroundView: UIView!
    
    @IBOutlet weak var buttonBackgroundViewTopConstant: NSLayoutConstraint!
    @IBOutlet var clothesButtonCollection: [UIButton]!
    @IBOutlet weak var sunglassButton: UIButton!
    @IBOutlet weak var shirtButton: UIButton!
    @IBOutlet weak var pantButton: UIButton!
    @IBOutlet weak var shoesButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: IBOutlet Function
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapClothesButton(_ sender: UIButton) {
        self.clothesButtonCollection.forEach { button in
            button.isSelected = false
        }
    }
    
    private func tapOneOfTheButtons(_ button: UIButton) {
        self.clothesButtonCollection.forEach { button in
            button.isSelected = false
        }
        
        if button == self.shirtButton {
            
        }
    }
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleFunction()
    }
    
    //MARK: Style Function
    private func styleFunction() {
        self.view.backgroundColor = UIColor.NColor.background
        self.configureNavigationLabel()
        self.configureButtonsBackgroundView()
    }
    
    private func configureNavigationLabel() {
        self.navigationTitle.font = UIFont.NFont.addWordNavigationTitle
        self.pointLabel.font = UIFont.NFont.noSearchedTextFont
    }
    
    private func configureButtonsBackgroundView() {
        self.buttonBackgroundView.backgroundColor = UIColor.NColor.white
        self.buttonBackgroundViewTopConstant.constant = UIScreen.main.bounds.height * 0.4
    }
    
    
}

