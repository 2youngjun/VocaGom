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
    var clothes: Clothes = .closet
    var user: User?
    
    //MARK: IBOutlet Variable
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var buttonBackgroundView: UIView!
    
    @IBOutlet weak var buttonBackgroundViewTopConstant: NSLayoutConstraint!
    
    @IBOutlet var clothesButtonCollection: [UIButton]!
    @IBOutlet weak var closetButton: UIButton!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var shirtButton: UIButton!
    @IBOutlet weak var pantButton: UIButton!
    @IBOutlet weak var shoesButton: UIButton!
    
    
    @IBOutlet weak var bearWidth: NSLayoutConstraint!
    @IBOutlet weak var bearHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var pantsImage: UIImageView!
    @IBOutlet weak var shoesImage: UIImageView!
    @IBOutlet weak var shirtImage: UIImageView!
    @IBOutlet weak var accessoryImage: UIImageView!
    @IBOutlet var clothesHeightCollection: [NSLayoutConstraint]!
    @IBOutlet var clothesWidthCollection: [NSLayoutConstraint]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: IBOutlet Function
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapClothesButton(_ sender: UIButton) {
        if sender.isSelected {
            return
        } else {
            self.clothesButtonCollection.forEach { button in
                button.isSelected = button == sender ? true : false
            }
        }
        
        self.configureButtonState(buttonCollection: self.clothesButtonCollection)
        
        if sender.tag == 0 {
            self.clothes = .closet
            self.collectionView.reloadData()
        } else if sender.tag == 1 {
            self.clothes = .sunglass
            self.collectionView.reloadData()
        } else if sender.tag == 2 {
            self.clothes = .shirt
            self.collectionView.reloadData()
        } else if sender.tag == 3 {
            self.clothes = .pants
            self.collectionView.reloadData()
        } else {
            self.clothes = .shoes
            self.collectionView.reloadData()
        }
        
    }
    
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleFunction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.user = CoreDataManager.shared.fetchUserInfo()
    }
    
    //MARK: Style Function
    private func styleFunction() {
        self.view.backgroundColor = UIColor.NColor.background
        self.configureNavigationLabel()
        self.configureCollectionView()
        self.configureButtonsBackgroundView()
        self.configureButtons()
        self.configureBearImage()
    }
    
    private func configureNavigationLabel() {
        self.navigationTitle.font = UIFont.NFont.addWordNavigationTitle
        self.pointLabel.font = UIFont.NFont.noSearchedTextFont
    }
    
    private func configureButtonsBackgroundView() {
        self.buttonBackgroundView.backgroundColor = UIColor.NColor.white
        self.buttonBackgroundViewTopConstant.constant = UIScreen.main.bounds.height * 0.4
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.NColor.backgroundBrown
    }
    
    private func configureButtons() {
        self.closetButton.tag = 0
        self.accessoryButton.tag = 1
        self.shirtButton.tag = 2
        self.pantButton.tag = 3
        self.shoesButton.tag = 4
        
        self.closetButton.isSelected = true
        // isNeed?
        self.configureButtonState(buttonCollection: self.clothesButtonCollection)
    }
    
    private func configureBearImage() {
        self.bearWidth.constant = UIScreen.main.bounds.width * 0.5
        self.bearHeight.constant = UIScreen.main.bounds.height * 0.3
        
        self.clothesWidthCollection.forEach { width in
            width.constant = self.bearWidth.constant
        }
        self.clothesHeightCollection.forEach { height in
            height.constant = self.bearHeight.constant
        }
    }
    
    
    // Changing button image/backgroundColor by state
    private func configureButtonState(buttonCollection: [UIButton]) {
        var selectedTag = 0
        
        self.clothesButtonCollection.forEach { button in
            if button.isSelected {
                selectedTag = button.tag
            }
        }
        self.clothesButtonCollection.forEach { button in
            if button.tag == selectedTag {
                button.setImage(UIImage(named: "tab\(selectedTag)_fill"), for: .selected)
                button.backgroundColor = UIColor.NColor.backgroundBrown
            } else {
                button.setImage(UIImage(named: "tab\(selectedTag)"), for: .selected)
                button.backgroundColor = UIColor.NColor.white
            }
        }
    }
}

extension PurchasingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.clothes {
        case .closet:
            return 0
        case .sunglass:
            return 0

        case .shirt:
            return 0

        case .pants:
            return 0

        case .shoes:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PurchasingCell", for: indexPath) as? PurchasingCell else { return UICollectionViewCell() }
        
        switch self.clothes {
        case .closet:
            return cell
        case .sunglass:
            return cell

        case .shirt:
            return cell

        case .pants:
            return cell

        case .shoes:
            return cell
        }
    }
}

extension PurchasingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 50) / 4, height: (UIScreen.main.bounds.width - 50) / 4 + 25)
    }
}
